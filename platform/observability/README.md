# Prometheus ve Grafana

Bu katman üniversite platformunun metrik tabanlı gözlemlenebilirliğini sağlar.

## Bileşenler

- Prometheus `3.13.2`: metrik toplama, PromQL ve alarm kuralları
- Grafana OSS `13.1.1`: izleme panosu ve sorgu görselleştirme
- Node Exporter `1.12.1`: DevOps-Lab CPU, bellek, disk ve işletim sistemi metrikleri

## Erişim

- Prometheus: `http://127.0.0.1:9090`
- Grafana: `http://127.0.0.1:3000`
- Node Exporter yalnızca VM içinde: `http://127.0.0.1:9102/metrics`

Grafana yöneticisinin parolası yalnızca VM'deki
`/home/vboxuser/.config/grafana/admin.env` dosyasında, `600` izinle tutulur.

## İzlenen hedefler

- Prometheus'un kendi sağlığı
- Kong Gateway istek ve gecikme metrikleri
- DevOps-Lab CPU, bellek, disk ve sistem metrikleri

Hazır gelen `Oracle University Platform` panosu hedef durumlarını, gateway
istek hızını ve VM kaynak kullanımını gösterir. `TargetDown`,
`HostMemoryLow` ve `HostDiskSpaceLow` alarm kuralları Prometheus'a yüklenir.

Bu tek düğümlü kurulum eğitim/geliştirme içindir. Üretimde uzun süreli metrik
depolama, Alertmanager bildirimleri, yüksek erişilebilirlik ve erişim
kontrolleri ayrıca tasarlanmalıdır.
