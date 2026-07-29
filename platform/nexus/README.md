# Nexus Repository

Nexus Repository bu VM'ye kurulmamıştır.

Güncel Nexus Repository sürümleri için Sonatype'ın belirttiği JVM bellek
gereksinimi, DevOps-Lab üzerinde Jenkins, K3s ve diğer servislerle birlikte
güvenli şekilde karşılanamamaktadır. Nexus veya Harbor çalışması ayrı ve en az
8 GiB RAM ayrılmış bir VM üzerinde yapılmalıdır.

Bu karar veri kaybını veya VM kilitlenmesini önlemek için verilmiştir.
