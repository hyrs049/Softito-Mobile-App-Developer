# CSS, Flutter ve React Native Soruları

---

## 1. Flexbox ile CSS Grid arasındaki mimari fark nedir ve ne zaman hangisi seçilmelidir?

Flexbox tek boyutlu, Grid iki boyutludur. Flexbox bir raftaki kitaplar gibi düşünülebilir: eşyaları tek bir sıraya dizersin, sıra dolarsa alt satıra geçer ama alt satırlar birbirinden habersizdir. Grid ise Excel tablosu ya da satranç tahtası gibidir, satır ve sütunu aynı anda planlarsın ve her şey bir hücreye oturur.

Mimari olarak Flexbox içerik odaklıdır, yani yerleşimi içeriğin boyutu belirler. Grid ise yerleşim odaklıdır, önce sayfanın iskeleti çizilir sonra içerik hücrelere konur.

| Özellik | Flexbox | CSS Grid |
|---|---|---|
| Boyut | Tek boyutlu (satır **veya** sütun) | İki boyutlu (satır **ve** sütun birlikte) |
| Yaklaşım | İçerik odaklı | Yerleşim odaklı |
| Benzetme | Raftaki kitaplar | Excel tablosu |
| Ne zaman seçilir | Menü çubuğu, buton grubu, kartın içindeki hizalama | Sayfanın ana iskeleti, kart galerisi, dashboard |

Pratikte ikisi birlikte kullanılır: iskeleti Grid kurar, kartların içini Flexbox düzenler.

---

## 2. CSS Grid'deki `fr` (fractional unit) birimi, geleneksel yüzde (`%`) birimine göre neden daha güvenlidir?

Yüzde, üst kutunun genişliğine göre hesap yapar ama aralardaki boşluğu (`gap`) hesaba katmaz. Mesela üç sütuna %33,3 verip aralarına 20px boşluk koyarsan toplam 100%'ü aşar ve sayfa yana taşar. Bir pastayı üçe bölüp dilimlerin arasına boşluk koymaya çalışmak gibi, pasta tamamı hesaplanmış olduğu için boşluğa yer kalmaz.

`fr` birimi ise önce boşlukları düşer, kalan alanı oranlara göre paylaştırır. `1fr 2fr` dersen kalan yerin üçte biri ve üçte ikisi olur. Bu yüzden hesap hep tutar ve taşma olmaz.

```css
/* Taşma riski var */
grid-template-columns: 33.3% 33.3% 33.3%;
gap: 20px;

/* Güvenli */
grid-template-columns: 1fr 1fr 1fr;
gap: 20px;
```

---

## 3. Neden "Desktop-First" (`max-width`) yerine "Mobile-First" (`min-width`) mimarisi tercih edilir?

Mobile-first mimarisinde temel kod telefon için yazılır, ekran büyüdükçe `min-width` ile "ekran en az bu kadarsa şunları ekle" denir. Küçük bir evle başlayıp arsa büyüdükçe oda eklemek gibidir. Desktop-first ise büyük evi yapıp sonra telefon için odaları tek tek yıkmaya benzer, çünkü `max-width` ile büyük ekran kuralları küçük ekranda tek tek geri alınır ve kod çakışır.

| | Mobile-First (`min-width`) | Desktop-First (`max-width`) |
|---|---|---|
| Başlangıç | Telefon (en sade hâl) | Masaüstü (en karmaşık hâl) |
| Ekran büyüyünce | Yeni kurallar **eklenir** | Yeni kural gerekmez |
| Ekran küçülünce | Yeni kural gerekmez | Kurallar **geri alınır** |
| Telefonda yük | Sadece gereken CSS çalışır | Önce büyük düzen okunur, sonra ezilir |

Telefonda sade kodun okunması sayfanın daha hızlı açılmasını sağlar. Ayrıca küçük ekranda yer az olduğu için hangi içeriğin gerçekten önemli olduğuna baştan karar vermek zorunda kalırsın. Bugün kullanıcıların büyük kısmı zaten telefondan girdiği için asıl kitleye göre başlamak mantıklıdır.

```css
/* Temel: telefon, tek sütun */
.grid { grid-template-columns: 1fr; }

/* Tablet ve üstü */
@media (min-width: 768px) {
  .grid { grid-template-columns: repeat(2, 1fr); }
}
```

---

## 4. CSS3'te `transition` ve `animation` yazarken neden `top`, `left`, `width` yerine `transform` ve `opacity` tercih edilmelidir?

Tarayıcı bir animasyon karesini çizerken üç iş yapar: önce elemanların yerini ve boyutunu hesaplar (layout), sonra boyar (paint), en son katmanları üst üste birleştirir (composite).

| Aşama | Ne yapar | Hangi özellikler tetikler | Maliyet |
|---|---|---|---|
| Layout | Boyut ve konumu hesaplar | `top`, `left`, `width`, `height` | En pahalı |
| Paint | Renk, gölge, arka planı boyar | `background`, `box-shadow` | Orta |
| Composite | Katmanları birleştirir | `transform`, `opacity` | En ucuz |

`top`, `left` ve `width` değişince ilk aşama tetiklenir, çünkü bir eleman kayınca komşularının yeri de yeniden hesaplanır. Bunu masadaki bütün eşyaları yeniden ölçüp dizmeye benzetebilirim. `transform` ve `opacity` ise sadece son aşamada çalışır, yani masadaki bir kağıdı olduğu gibi kaydırmak gibi, diğer eşyalara dokunmaz. Bu iş çoğunlukla ekran kartında (GPU) yapıldığı için animasyon saniyede 60 kare hızında akıcı kalır, telefonun bataryası da daha az harcanır.

---

## 5. CSS Grid'de `auto-fit` ile `minmax()` birleşimi nasıl çalışır ve responsive tasarım açısından ne avantaj sağlar?

`minmax(240px, 1fr)` bir sütunun en az 240px, en çok kalan alanın eşit payı kadar olabileceğini söyler. `repeat(auto-fit, ...)` ise "bu genişliğe kaç sütun sığıyorsa o kadar sütun aç" demektir.

```css
.kartlar {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 18px;
}
```

| Ekran genişliği | Oluşan sütun sayısı |
|---|---|
| 1000px | 4 |
| 500px | 2 |
| 300px | 1 |

Kitaplığa kitap dizmeye benzer: her kitap en az belli bir genişlikte, raf genişledikçe daha fazla kitap sığar, artan boşluk da kitaplara paylaştırılır. `auto-fit` boş kalan sütunları çökertir, kartlar boşluğu doldurur. Avantajı, ekstra bir media query yazmaya gerek kalmadan sayfanın her ekrana kendi kendine uyum sağlaması ve kartların hiç sıkışmamasıdır.

---

## 6. `grid-template-areas` özelliğinin sağladığı en büyük kurumsal avantaj nedir?

`grid-template-areas` ile sayfa düzeni, kodun içinde isimlerle ve neredeyse çizim gibi görünecek şekilde yazılır.

```css
.sayfa {
  display: grid;
  grid-template-areas:
    "header header"
    "nav    main"
    "footer footer";
}
```

En büyük kurumsal avantajı okunabilirlik ve bakım kolaylığıdır. Bir binanın kat planında odaların üstünde isim yazması gibi, projeye sonradan giren biri sayfanın nasıl dizildiğini tek bakışta anlar. Bir de yerleşim HTML sırasından bağımsız olduğu için mobilde başka düzen istendiğinde sadece alan haritası değiştirilir, HTML'e hiç dokunulmaz. Yapı (HTML) ile görünümü (CSS) birbirinden ayırmak, çok kişinin çalıştığı büyük projelerde hata riskini azaltır.

---

## 7. CSS'te `clamp()` fonksiyonunun 3 parametresi ne anlama gelir?

`clamp(en küçük, tercih edilen, en büyük)` şeklinde üç parametresi vardır. Bir ses düğmesine alt ve üst sınır koymak gibidir.

```css
h1 {
  font-size: clamp(2rem, 5vw, 4rem);
}
```

| Parametre | Değer | Anlamı |
|---|---|---|
| 1. (minimum) | `2rem` | Yazı bunun altına inmez |
| 2. (tercih edilen) | `5vw` | Arada ekran genişliğinin %5'i kadar büyüyüp küçülür |
| 3. (maksimum) | `4rem` | Yazı bunun üstüne çıkmaz |

Böylece başlık boyutu için ayrı media query yazmaya gerek kalmaz.

---

## 8. Bir CSS animasyonunun sonsuza kadar kesintisiz çalışması için hangi CSS kuralı kullanılır?

`animation-iteration-count: infinite` kuralı kullanılır. Kısa yazımda `animation: pulse 2s infinite;` şeklinde de yazılır. `infinite`, animasyonun bittiği yerde durmayıp başa dönüp sonsuza kadar tekrar etmesini sağlar. Dönme dolabın durmadan dönmesi gibi.

```css
.pulse-dot {
  animation: pulse 2s infinite;
}

@keyframes pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50%      { opacity: 0.4; transform: scale(1.4); }
}
```

Kesintisiz görünmesi için `@keyframes` içinde `0%` ile `100%` karesini aynı yapmak iyi olur, yoksa her turda küçük bir sıçrama olur.

---

## 9. Flutter'da CSS Grid'in ve Flexbox'ın doğrudan karşılığı olan widget'lar nelerdir?

| CSS | Flutter karşılığı | Açıklama |
|---|---|---|
| `display: flex` (yatay) | `Row` | Öğeleri yan yana dizer |
| `display: flex` (dikey) | `Column` | Öğeleri alt alta dizer |
| `flex: 1` | `Expanded` / `Flexible` | Öğelere boş alandan pay verir |
| `flex-wrap: wrap` | `Wrap` | Satır dolunca alta geçer |
| `justify-content` | `mainAxisAlignment` | Ana eksende hizalama |
| `align-items` | `crossAxisAlignment` | Çapraz eksende hizalama |
| `display: grid` | `GridView` | Izgara düzeni |
| `repeat(3, 1fr)` | `GridView.count` | Sabit sütun sayısı verilir |
| `repeat(auto-fit, minmax(...))` | `GridView.extent` veya `SliverGridDelegateWithMaxCrossAxisExtent` | En geniş kutu ölçüsü verilir, sütun sayısını Flutter bulur |

Büyük listelerde `GridView.builder` tercih edilir. `GridView.extent`, `auto-fit` ve `minmax` mantığına en yakın olandır. Flutter'da CSS yoktur, her şey widget ağacıyla kurulur.

---

## 10. React Native'de CSS Grid kullanılabilir mi? Kullanılamıyorsa çok sütunlu ızgara yapısı nasıl oluşturulabilir?

Standart bir React Native projesinde CSS Grid kullanılamaz, çünkü React Native tarayıcı çalıştırmaz. Yerleşimi Yoga adlı bir motor yapar ve Yoga Flexbox mantığıyla çalışır, varsayılan yön de dikeydir (`column`). Çok sütunlu ızgara için üç yol var.

**Birincisi:** `FlatList` bileşenine `numColumns` vermek. `numColumns` sonradan değişecekse `FlatList`'in `key` değeri de değiştirilmelidir.

```jsx
<FlatList
  data={urunler}
  numColumns={2}
  renderItem={({ item }) => <Kart urun={item} />}
/>
```

**İkincisi:** Bir `View` içinde `flexDirection: 'row'` ile `flexWrap: 'wrap'` kullanıp her öğeye `width: '48%'` gibi bir değer vermek.

```jsx
const styles = StyleSheet.create({
  satir: { flexDirection: 'row', flexWrap: 'wrap', justifyContent: 'space-between' },
  kart:  { width: '48%', marginBottom: 12 },
});
```

**Üçüncüsü:** `useWindowDimensions` ile ekran genişliğini okuyup sütun sayısını buna göre hesaplamak, böylece `auto-fit` benzeri bir davranış elde edilir.

```jsx
const { width } = useWindowDimensions();
const sutunSayisi = Math.floor(width / 160);
```
