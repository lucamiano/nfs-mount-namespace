package mutation

import (
	"context"
	"fmt"
	"strconv"

	"github.com/sirupsen/logrus"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	rest "k8s.io/client-go/rest"
)

var configMapName = "uid-mapping"
var namespace = "nfs"

// minLifespanTolerations is a container for mininum lifespan mutation
type mountHomeDirectory struct {
	Logger logrus.FieldLogger
}

// minLifespanTolerations imhdements the podMutator interface
var _ podMutator = (*mountHomeDirectory)(nil)

// Name returns the minLifespanTolerations short name
func (mhd mountHomeDirectory) Name() string {
	return "mount_home_directory"
}

// Mutate returns a new mutated pod according to lifespan tolerations rules
func (mhd mountHomeDirectory) Mutate(pod *corev1.Pod) (*corev1.Pod, error) {

	mhd.Logger = mhd.Logger.WithField("mutation", mhd.Name())
	mpod := pod.DeepCopy()
	securityContext := pod.Spec.SecurityContext

	if securityContext == nil || securityContext.RunAsUser == nil {
		mhd.Logger.WithField("mount_home_directory", 0).
			Printf("no runAsUser rule found, applying default for current ServiceAccount")

		serviceAccount := pod.Spec.ServiceAccountName
		var err error
		mpod.Spec.SecurityContext, err = setUID(mpod.Spec.SecurityContext, serviceAccount)
		if err != nil {
			return nil, fmt.Errorf("Failed to set RunAsUser: %s\n", err)
		}
	}
	return mpod, nil
}

// Set RunAsUser field based on ServiceAccountName
func setUID(existing *corev1.PodSecurityContext, serviceAccount string) (*corev1.PodSecurityContext, error) {
	client, err := initClient()
	if err != nil {
		return nil, fmt.Errorf("Failed setting UID: %s\n", err)
	}
	configMap, err := getConfigMap(client)
	if err != nil {
		return nil, fmt.Errorf("Failed setting UID: %s\n", err)
	}
	data := configMap.Data
	uid, err := strconv.ParseInt(data[serviceAccount], 10, 64)
	if err != nil {
		return nil, fmt.Errorf("failed to convert UID to int64: %v", err)
	}
	existing.RunAsUser = &uid
	return existing, nil
}

// Init Kubernetes Client to interact with the API
func initClient() (*kubernetes.Clientset, error) {
	// Init client from inside pod
	config, err := rest.InClusterConfig()
	if err != nil {
		return nil, fmt.Errorf("Error getting in-cluster config: %s\n", err)
	}

	// Creating client
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		return nil, fmt.Errorf("Error creating Kubernetes client: %s\n", err)
	}
	return clientset, nil
}

// Retrieve ConfigMap based on name and namespaces
func getConfigMap(client *kubernetes.Clientset) (*corev1.ConfigMap, error) {
	// Get ConfigMap
	configMap, err := client.CoreV1().ConfigMaps(namespace).Get(context.TODO(), configMapName, metav1.GetOptions{})
	if err != nil {
		return nil, fmt.Errorf("Error getting ConfigMap: %s\n", err)
	}
	return configMap, nil
}
