# 🖥️ Szablony Kiosków

Zestaw nowoczesnych, responsywnych szablonów UI do zastosowania w kioskach samoobsługowych Kiosk Zero, Kiosk Core, Kiosk Easy i Kiosk Pro. Zawarte w repozytorium materiały przeznaczone są do budowy interfejsu dla kiosków sprzedażowych, systemów sprzedazy POS, infomatów, automatów biletowych, systemów monitoringu itp.


## ✨ Funkcje

- 📐 Gotowe layouty pod ekrany dotykowe (FullHD / pion / poziom)
- 🧩 Modułowa struktura szablonów (łatwa personalizacja)
- 🎨 Możliwość brandingu (logo, kolory, czcionki)
- 🖼️ Obsługa ikon i grafik kategorii / produktów
- 🌐 Wielojęzyczność (i18n)
- ♿ Przyjazne dla dostępności (duże przyciski, kontrast, tryb high-contrast)
- ⚡ Lekkie i szybkie – zoptymalizowane pod stosowany w kioskach hardware

## 🚀 Jak używać
 - zmień style CSS, zmień układ wizualny, NIE ZMIENIAJ identyfikatorów obiektów (parametr "id"). Oprogramowanie kiosku na podstawie identyfikatorów uruchomi odpowiednie funkcje
 - szablon mozesz wgrać do swojego konta w panelu B2B: 👉 https://b2b.bigdotsoftware.eu lub wystawić w swojej domenie np.: 👉 https://mojadomena.pl/test-integracja.html lub 👉 https://bigdotsoftware.pl/test-integracja.html
 - Jeśli wgrasz szablon do swojego konta w panelu B2B: 👉 https://b2b.bigdotsoftware.eu, wówczas w ustawieniach kiosku ustaw "Źródło danych kiosku" na "B2B Panel Partnerski". Kiosk automatycznie zsychnronizuje się z Twoim kontem B2B i wczyta wgrany szablon. ![Ustawienia](img2.png)
 - Jeśli wystawisz szablon w swojej domenie, wówczas w ustawieniach kiosku ustaw "Źródło danych kiosku" na "Własne źródło". ![Ustawienia](img1.png)
 
 Jeśli chcesz zbudować własny interfejs, a aktualny model szablonów nie daje takiej możliwości lub wymaga modyfikacji zachowania, skontaktuj się z nami. 
  
 Alternatywnie możesz pominąć ładowanie pliku kiosk.js, stworzyć własny kod korzystający z backendu Kiosku.



## 📦 Tutorial

Ten krótki tutorial pokazuje, jak krok po kroku rozwijać własne szablony w prostym flow kiosku – od automatycznego dodania produktu aż po pełną obsługę zamówienia i płatności.

### 🧩 Krok 1: Dodawanie produktu

Za pomocą metody:

```js
kiosk.addToCart(product);
```

produkt zostaje dodany do koszyka. Następnie system automatycznie rozpoczyna proces zamówienia, płatności oraz wydruku.

Przykładowy przycisk inicjujący:

```html
<button id="orderNowBtn">Zapłać</button>
```

Konieczne jest również wczytanie SDK kiosku:

```html
<script src="/kiosk.js" defer></script>
```

### 🧩 Krok 2: Pasek koszyka

Dodaj element:

```html
<div id="cartBar"></div>
```

Element ten automatycznie wyświetla podsumowanie koszyka.


### 🧩 Krok 3: Widok zamówienia

Dodaj kontener:

```html
<div id="orderList" class="hidden"></div>
```

Służy on do prezentowania podsumowania koszyka. Zawiera trzy przyciski:

```html
<button id="backBtn">⬅ Produkty</button>
<button id="payNowBtn">Zapłać</button>
<button id="orderNowBtn">Zamów</button>
```

- **⬅ Produkty** – powrót do listy produktów  
- **Zapłać** – przejście do płatności  
- **Zamów** – SDK kiosku zadba o to aby był widoczny tylko wtedy, gdy kiosk nie posiada dostępnych metod płatności  


### 🧩 Krok 4: Modale informacyjne

Dodaj dwa elementy:

```html
<div id="infoModal" class="hidden"></div>
<div id="resultModal" class="hidden"></div>
```

- `infoModal` – wyświetla informacje i błędy  
- `resultModal` – prezentuje wynik zamówienia  

Jeśli wczytane zostanie SDK do obsługi kodów QR, w `resultModal` automatycznie pojawi się wygenerowany kod QR.

### 🧩 Krok 5: Integracja zaawansowana

Jeśli standardowy przebieg płatności jest niewystarczający (np. potrzebna jest integracja z dodatkowym systemem lub debugowanie kolejnych etapów przetwarzania transakcji), istnieje możliwość wpięcia własnego kodu JavaScript w dowolnym punkcie procesu. Poniższy diagram przedstawia pełny flow przetwarzania płatności w kiosku — od inicjalizacji płatności na terminalu, przez utworzenie zamówienia, aż po fiskalizację na końcu.

![Flow](kiosk-payment-flow.png)

Zielone prostokąty reprezentują kolejne etapy procesu, natomiast pomarańczowe strzałki opisują nazwy emitowanych eventów. Aby w szablonie odbierać eventy z poszczególnych etapów, należy zarejestrować funkcję callback:

```js
kiosk.registerPaymentCallback(my_func);

function my_func(event) {
    var continueFlow = false;
    if( event.type === 'step_order_start') {
        // Rozpoczyna się tworzenie zamówienia
        // Ewentualnie przerwać flow transakcji Kiosku ustawiając continueFlow=false
    }
    else if( event.type === 'step_order_end') {
        // Zakończyło się tworzenie zamówienia
        if( event.ok === true) {
            // Etap zakonczył sie sukcesem
            // W tym miejscu można wywołać dodatkowy backend
            // Ewentualnie przerwać flow transakcji Kiosku ustawiając continueFlow=false
        }else{
            // Etap zakonczył sie bledem
            console.log(`ERROR: ${JSON.stringify(event.data)}`);
        }
    }
    return continueFlow;
}
```

Można również zarejestrować funkcję asynchroniczną, w tym celu należy użyć registerPaymentCallbackAsync.

```js
kiosk.registerPaymentCallbackAsync(my_async_func);

async function my_async_func(event) {

}
```


## 📜 Licencja

MIT – możesz używać komercyjnie, modyfikować i dystrybuować.

## 📬 Kontakt

Jeśli tworzysz swój własny szablon kiosku, skontaktuj się z nami - pomożemy Ci to zrobić szybko i efektywnie.

https://bigdotsoftware.pl/
bigdotsoftware@bigdotsoftware.pl
