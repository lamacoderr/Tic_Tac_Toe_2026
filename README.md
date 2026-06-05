Tris in Assembly x86 (emu8086)
Tris e un gioco console scritto in Assembly x86 per l'emulatore emu8086. Il programma gestisce una partita a due giocatori su una griglia 3x3, controlla le condizioni di vittoria o pareggio, tiene i punteggi e permette di rigiocare.
Il progetto e stato realizzato come esercizio didattico di programmazione in Assembly.
Funzionalita
Gioco a due giocatori in locale (X contro O)
Griglia 3x3 con numeri da 1 a 9 per la scelta delle caselle
Input da tastiera con controllo della validita
Verifica automatica delle combinazioni vincenti (righe, colonne, diagonali)
Rilevamento del pareggio quando tutte le caselle sono piene
Conteggio dei punteggi tra partite multiple
Possibilita di rigiocare o uscire alla fine di ogni partita
Pulizia dello schermo tra un turno e l'altro
File del progetto
Table
File	Descrizione
tris.asm	File principale con il codice sorgente Assembly
Requisiti
Per compilare ed eseguire il progetto servono:
L'emulatore emu8086 installato su Windows
Il file tris.asm nella cartella di lavoro
Compilazione ed esecuzione
Apri emu8086
Carica il file tris.asm
Clicca su Compile and Emulate (o premi F5)
Il programma si avvia nella finestra dell'emulatore
Nota importante
Il programma usa gli interrupt del DOS (int 21h) per leggere e scrivere testo, e gli interrupt del BIOS (int 10h) per pulire lo schermo. Per questo motivo funziona solo dentro l'emulatore emu8086 o su un sistema DOS reale.
Se il programma non si avvia, controlla che:
emu8086 sia aperto correttamente
il file tris.asm sia caricato senza errori di sintassi
il modello di memoria sia impostato su SMALL
Menu del programma
All'avvio il programma mostra il messaggio di benvenuto e aspetta che l'utente premi un tasto. Poi entra nel ciclo di gioco:
plain
X tocca a te. Scegli casella (1-9):
Dopo ogni mossa la griglia viene aggiornata e stampata a schermo. Quando la partita finisce, il programma chiede:
plain
Vuoi rigiocare? (s/n):
Digitare s per una nuova partita, n per uscire.
Concetti di programmazione usati
Il progetto utilizza diversi argomenti fondamentali di Assembly x86:
Modello di memoria SMALL con segmenti .data, .stack e .code
Registri AX, BX, CX, DX, SI, DI per operazioni e indirizzamento
Interrupt DOS (int 21h) per input/output su console
Interrupt BIOS (int 10h) per la gestione dello schermo
Procedure (PROC / ENDP) per dividere il codice in blocchi riutilizzabili
Stack per salvare e ripristinare i registri nelle procedure
Cicli con istruzione LOOP
Condizioni con CMP e salti condizionati (JE, JNE, JB, JA)
Array di word (dw) per memorizzare gli offset delle caselle
Buffer di input per la lettura da tastiera con int 21h funzione 0Ah
Conversione da ASCII a numero e viceversa
Autore
Progetto sviluppato individualmente come esercitazione di programmazione in Assembly.
Studente: Abdul
Istituto: ITIS Paleocapa
Docente: Prof. Franco Baldacci
Materia: Assembly / Informatica
Anno Scolastico: 2025/2026
