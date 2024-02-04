# **Algoritmus pro klasifikaci fyzických aktivit z akcelerometrických signálů**

V této technické dokumentaci je popsán kód funkce rozpoznaniAktivit, která na základě
vstupní matice D rozpoznává typ aktivity, která byla vykonána.
Funkce nejprve rozdělí data na osy x, y a z a odečte od nich jejich průměrnou hodnotu.
Následně spočítá průchody signálu 0 pro hodnoty y1 větší než ±0.02 a maximální frekvenci
ve spektru pro y1.

Pokud počet průchodů signálu 0 pro hodnoty y1 je menší než 25 a maximální frekvence ve
spektru pro y1 je menší než 0.7, pak se jedná o pády, lehnutí nebo skákání a funkce
provede filtrace signálu y1 a spočítá průchody signálu 0 pro filtrovaný signál. Pokud je počet
průchodů signálu 0 pro filtrovaný signál větší než 6 a maximum hodnoty y1 je větší než 2,
pak se jedná o skákání. Pokud je počet průchodů signálu 0 pro filtrovaný signál menší než 6,
funkce vypočítá různé charakteristiky signálů x1, y1 a z1 a na jejich základě určí, zda se
jedná o pád dopředu, pád dozadu, lehnutí, pád do boku nebo jiný typ aktivity.

Pokud počet průchodů signálu 0 pro hodnoty y1 je větší než 25 a maximální frekvence ve
spektru pro y1 je větší než 0.7, pak se jedná o chůzi nebo běh a funkce spojí signály x1, y1
a z1, spočítá píky vzniklé při pohybu a na jejich základě určí, zda se jedná o běh nebo chůzi.

Signály zařazené ve skupině pro chůzi jsou filtrovány a následně vyhlazeny. Ve vyhlazeném
signálu jsou spočítány píky a pokud je jejich počet menší než 2 tak se jedná o chůzi. Signály
pro chůzi nahoru do schodů a dolů ze schodů jsou rozlišeny podle vzdálenosti mezi 2
nalezenými píky a oddělené druhé poloviny z1, která je umocněna, filtrována a jsou v ní
spočítány píky. Pokud je počet píku větší než 2, jedná se o chůzi dolů ze schodů a v
opačném případě se jedná o chůzi nahoru do schodů.
