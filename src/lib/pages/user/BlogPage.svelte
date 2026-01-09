<script lang="ts">
  const articles = [
    { title: "Tips UMKM: Cara Foto Produk Pakai HP", excerpt: "Mau jualan makin laris? Coba tips foto produk simple ini...", category: "Tips", date: "8 Jan 2024", image: "https://picsum.photos/seed/blog1/400/250" },
    { title: "Promo Januari: Gratis Ongkir!", excerpt: "Nikmati gratis ongkir ke seluruh area desa kita sepanjang bulan ini.", category: "Promo", date: "5 Jan 2024", image: "https://picsum.photos/seed/blog2/400/250" },
    { title: "Cerita Toko: Rahasia Sate Bang Kumis", excerpt: "Kisah di balik lezatnya sate yang sudah bertahan 20 tahun.", category: "Cerita Toko", date: "2 Jan 2024", image: "https://picsum.photos/seed/blog3/400/250" },
  ];
</script>

<div class="blog-page">
  <header class="header bg-primary sticky-top shadow-soft">
    <h1>OrbFood Blog</h1>
    <div class="header-icons">
      <span class="icon">🔍</span>
      <span class="icon">👤</span>
    </div>
  </header>

  <main class="content">
    <section class="hero-card rounded-lg shadow-soft">
      <img src="https://picsum.photos/seed/hero/600/300" alt="Hero" class="hero-image" />
      <div class="hero-overlay">
        <span class="badge bg-accent">Terbaru</span>
        <h2>Gabung Jadi Mitra OrbFood Sekarang!</h2>
        <button class="cta-btn bg-accent">Lihat Menu</button>
      </div>
    </section>

    <div class="article-list">
      {#each articles as article}
        <div class="article-card shadow-soft rounded-lg">
          <img src={article.image} alt={article.title} class="article-image" />
          <div class="article-info">
            <span class="badge bg-accent">{article.category}</span>
            <h3 class="article-title">{article.title}</h3>
            <p class="article-excerpt">{article.excerpt}</p>
            <span class="article-date">{article.date}</span>
          </div>
        </div>
      {/each}
    </div>
  </main>
</div>

<style>
  .blog-page {
    display: flex;
    flex-direction: column;
    flex: 1;
  }

  .header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 16px;
    color: white;
  }

  .header h1 {
    margin: 0;
    font-size: 18px;
  }

  .header-icons {
    display: flex;
    gap: 16px;
  }

  .content {
    padding: 16px;
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .hero-card {
    position: relative;
    height: 200px;
    overflow: hidden;
  }

  .hero-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
  }

  .hero-overlay {
    position: absolute;
    inset: 0;
    background: linear-gradient(0deg, rgba(0,0,0,0.8) 0%, rgba(0,0,0,0) 100%);
    padding: 16px;
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
    color: white;
  }

  .hero-overlay h2 {
    margin: 8px 0;
    font-size: 18px;
  }

  .badge {
    align-self: flex-start;
    font-size: 10px;
    padding: 4px 8px;
    border-radius: 4px;
    font-weight: 600;
  }

  .cta-btn {
    margin-top: 8px;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    color: white;
  }

  .article-card {
    background: white;
    margin-bottom: 16px;
    overflow: hidden;
  }

  .article-image {
    width: 100%;
    height: 160px;
    object-fit: cover;
  }

  .article-info {
    padding: 12px;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .article-title {
    margin: 4px 0;
    font-size: 16px;
    font-weight: 600;
  }

  .article-excerpt {
    font-size: 13px;
    color: var(--text-muted);
    margin: 0;
  }

  .article-date {
    font-size: 11px;
    color: var(--text-hint);
    margin-top: 8px;
  }
</style>
