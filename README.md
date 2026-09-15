# Çeyiz Defteri — Supabase kurulumu

## 1. Supabase veritabanını kurun

1. Supabase projenizde **SQL Editor** açın.
2. `supabase-setup.sql` dosyasının tamamını yapıştırıp **Run** seçin.
3. **Authentication > Providers > Email** bölümünde e-posta/şifre girişinin etkin olduğundan emin olun.
4. Geliştirme aşamasında doğrulama e-postası istemiyorsanız **Confirm email** ayarını kapatın. Canlı kullanımda doğrulamanın açık olması önerilir.

## 2. İstemci yapılandırmasını ekleyin

1. Supabase **Project Settings > API** sayfasından Project URL ve **anon public** key değerini alın.
2. `supabase-config.js` içindeki `SUPABASE_URL` ve `SUPABASE_ANON_KEY` yer tutucularını bu değerlerle değiştirin.
3. `service_role` key'i asla bu dosyaya, GitHub'a veya tarayıcıya eklenmemelidir.

> Saf statik HTML sitelerinde Vercel ortam değişkenleri tarayıcı JavaScript'ine otomatik verilmez. Bu nedenle anon public key bu istemci yapılandırmasında bulunur; güvenlik Row Level Security politikalarıyla sağlanır.

## 3. Ortak ev listesi oluşturun

1. Siteyi açın ve ilk hesabı oluşturun/giriş yapın.
2. **Yeni ev oluştur** seçeneğiyle ortak ev listesini oluşturun.
3. Hesap çubuğunda gösterilen davet kodunu nişanlınızla paylaşın.
4. Nişanlınız ayrı hesapla giriş yapar, **Mevcut eve katıl** seçeneğini seçer ve kodu girer.
5. İkiniz de aynı ürünleri görür ve güncellersiniz.

## 4. GitHub ve Vercel'e yayınlayın

Yapılandırma değerlerini ekledikten sonra terminalde çalıştırın:

```bash
cd C:/Workspace/ceyiz-defteri
git add index.html supabase-config.js supabase-setup.sql README.md
git commit -m "Add shared Supabase household storage"
git push
```

Vercel, bağlı GitHub dalındaki değişikliği algılar ve otomatik deployment başlatır.
