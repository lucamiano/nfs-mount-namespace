package validation

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"github.com/sirupsen/logrus"
	admissionv1 "k8s.io/api/admission/v1"
	corev1 "k8s.io/api/core/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes"
	rest "k8s.io/client-go/rest"
)

var configMapName = "nfs-pod-access-control-uid-mapping"
var namespace = "default"

// uidValidator is a container for validating the name of pods
type uidValidator struct {
	Logger logrus.FieldLogger
}

// uidValidator implements the podValidator interface
var _ podValidator = (*uidValidator)(nil)

// Name returns the name of nameValidator
func (n uidValidator) Name() string {
	return "uid_validator"
}

// Validate inspects the Pod Spec.
// The returned validation is only valid if the Pod doesn't set runAsUser with an unappropriate UID.
// UID is associated with Pod through ServiceAccount
func (n uidValidator) Validate(pod *corev1.Pod, a *admissionv1.AdmissionRequest) (validation, error) {

	securityContext := pod.Spec.SecurityContext
	serviceAccount := getServiceAccount(n, a)

	if securityContext.RunAsUser != nil {
		found := securityContext.RunAsUser
		client, err := initClient()
		if err != nil {
			v := validation{
				Valid:  false,
				Reason: fmt.Sprintf("Failed initializing Kubernetes client: %s\n", err),
			}
			return v, nil
		}
		configMap, err := getConfigMap(client)
		if err != nil {
			v := validation{
				Valid:  false,
				Reason: fmt.Sprintf("Failed getting ConfigMap: %s\n", err),
			}
			return v, nil
		}
		data := configMap.Data
		expected, err := strconv.ParseInt(data[serviceAccount], 10, 64)
		if err != nil {
			v := validation{
				Valid:  false,
				Reason: fmt.Sprintf("Failed to convert UID to int64\n: %s", err),
			}
			return v, nil
		}
		if expected != *found {
			v := validation{
				Valid:  false,
				Reason: fmt.Sprintf("Invalid uid, expected: %d, found: %d\n", expected, *found),
			}
			return v, nil
		}
	}

	return validation{Valid: true, Reason: "Valid uid"}, nil
}

// Init Kubernetes Client to interact with the API
func initClient() (*kubernetes.Clientset, error) {
	// Init client from inside pod
	config, err := rest.InClusterConfig()
	if err != nil {
		logMessage := fmt.Sprintf("Error getting in-cluster config: %s\n", err)
		return nil, fmt.Errorf(logMessage)
	}

	// Creating client
	clientset, err := kubernetes.NewForConfig(config)
	if err != nil {
		logMessage := fmt.Sprintf("Error starting Kubernetes client from config: %s\n", err)
		return nil, fmt.Errorf(logMessage)
	}
	return clientset, nil
}

// Retrieve ConfigMap based on name and namespaces
func getConfigMap(client *kubernetes.Clientset) (*corev1.ConfigMap, error) {
	// Get ConfigMap
	configMap, err := client.CoreV1().ConfigMaps(namespace).Get(context.TODO(), configMapName, metav1.GetOptions{})
	if err != nil {
		logMessage := fmt.Sprintf("Error getting ConfigMap: %s\n", err)
		return nil, fmt.Errorf(logMessage)
	}
	return configMap, nil
}

// Get ServiceAccount from API request
func getServiceAccount(mhd uidValidator, request *admissionv1.AdmissionRequest) string {
	userInfo := request.UserInfo
	if userInfo.Username != "" && strings.HasPrefix(userInfo.Username, "system:serviceaccount:") {
		parts := strings.Split(userInfo.Username, ":")
		if len(parts) == 4 {
			namespace := parts[2]
			serviceAccountName := parts[3]
			logMessage := fmt.Sprintf("Request made by ServiceAccount: %s in namespace: %s", serviceAccountName, namespace)
			mhd.Logger.Info(logMessage)

			return serviceAccountName
		}
	}
	return ""
}
