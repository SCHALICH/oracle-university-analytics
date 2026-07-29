# Kubernetes / K3s

DevOps-Lab, tek düğümlü K3s geliştirme kümesi olarak çalışır. Kaynakları korumak
için K3s içindeki Traefik, ServiceLB ve metrics-server devre dışıdır; CoreDNS ve
local-path kalıcı depolama sağlayıcısı etkindir.

`base.yaml` aşağıdaki bileşenleri kurar:

- `university-platform` namespace
- Kalıcı 1 GiB Redis diski ve Redis servisi
- FastAPI Deployment ve ClusterIP servisi
- Nginx Deployment ve `30080` NodePort servisi
- Hazırlık/canlılık kontrolleri, kaynak sınırları ve yetkisiz kullanıcı ayarları

## Kurulum

Özel API ve Nginx imajları önce K3s containerd deposuna aktarılır. Ardından:

```bash
kubectl apply -f platform/kubernetes/base.yaml
kubectl rollout status deployment/redis -n university-platform
kubectl rollout status deployment/oracle-university-api -n university-platform
kubectl rollout status deployment/oracle-university-nginx -n university-platform
```

## Doğrulama

```bash
kubectl get all,pvc -n university-platform
curl http://127.0.0.1:30080/health
curl http://127.0.0.1:30080/api/v1/project
```

VirtualBox NAT yönlendirmesiyle Windows erişimi:

- Podman sürümü: `http://127.0.0.1:8080`
- Kubernetes sürümü: `http://127.0.0.1:8081`
