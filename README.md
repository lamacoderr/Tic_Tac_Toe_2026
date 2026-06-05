# ♟️ Tris (Tic-Tac-Toe) in Assembly x86

[![Assembly](https://img.shields.io/badge/Language-Assembly%20x86-blue.svg)](https://en.wikipedia.org/wiki/Assembly_language)
[![Emulator](https://img.shields.io/badge/Emulator-emu8086-orange.svg)](http://www.emu8086.com/)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)]()

Progetto individuale di un gioco del Tris sviluppato in **Assembly x86 a 16-bit** per l'emulatore **emu8086**.

**Studente:** Abdul | **Istituto:** ITIS Paleocapa | **Docente:** Prof. Franco Baldacci

---

## ✨ Caratteristiche
- 🎮 **Modalità 2 giocatori** locale (X e O a turno sulla stessa tastiera).
- 🛡️ **Validazione input**: controlla che le mosse siano valide (1-9) e che la casella sia libera.
- 🏆 **Controllo vittorie e pareggi**: verifica automatica di tutte le righe, colonne e diagonali.
- 📊 **Punteggio persistente**: tiene traccia delle vittorie e dei pareggi tra più partite consecutive.

---

## 🚀 Come Eseguire
1. Scarica e installa [emu8086](http://www.emu8086.com/).
2. Apri il file `Tic_Tac_Toe__Game_2026.asm` con l'emulatore.
3. Clicca su **"Emulate"** per il debug passo-passo o **"Run"** per giocare direttamente.

---

## 🎮 Come si Gioca
I giocatori inseriscono un numero da **1 a 9** per selezionare la casella corrispondente:
```text
 1 | 2 | 3 
---+---+---
 4 | 5 | 6 
---+---+---
 7 | 8 | 9 
