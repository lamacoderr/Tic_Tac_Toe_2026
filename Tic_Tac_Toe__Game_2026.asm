; ============================================
; PROGETTO: TRIS in Assembly x86
; Nome: Abdul
; Scuola: ITIS Paleocapa
; Professore: Franco Baldacci
; Materia: Assembly / Computer Organisation
; 
; Fatto da solo, non copiato dai gruppi
; ============================================

.model small
.stack 100h

.data
    ; queto e' il tabellone, ho messo i numeri cosi si sa dove cliccare
    ; 13,10 serve per andare a capo (l'ho imparato a lezione)
    griglia db " 1 | 2 | 3 ",13,10
            db "   |   |   ",13,10
            db "   |   |   ",13,10
            db "---+---+---",13,10
            db " 4 | 5 | 6 ",13,10
            db "   |   |   ",13,10
            db "   |   |   ",13,10
            db "---+---+---",13,10
            db " 7 | 8 | 9 ",13,10
            db "   |   |   ",13,10
            db "   |   |   ",13,10,'$'

    ; offset delle caselle, ho contato a mano nella stringa
    ; 1=1, 2=5, 3=9... e cosi via
    posizioni dw 1, 5, 9, 53, 57, 61, 105, 109, 113

    ; variabili del gioco
    turno db 'X'          ; inizia sempre X
    vince db 0            ; 0=nessuno, 1=vince qualcuno, 2=pareggio
    puntiX db 0           ; quante volte ha vinto X
    puntiO db 0           ; quante volte ha vinto O
    pari db 0             ; i pareggi (cats nel inglese)

    ; messaggi per l'utente, tutti in italiano
    benvenuto db "Benvenuto al Tris di Abdul!",13,10
              db "Premi un tasto qualsiasi per iniziare...",13,10,'$'
    
    chiediRigioca db 13,10,"Vuoi rigiocare? (s/n): $"
    
    arrivederci db 13,10,"Grazie per aver giocato! Ciao.",13,10,'$'
    
    ; il turno: stampo il carattere del giocatore poi questo messaggio
    msgTurno db " tocca a te. Scegli casella (1-9): $"
    
    msgErrore db "Non valido! Riprova (1-9): $"
    
    msgPareggio db 13,10,"Pareggio! Nessuno vince.",13,10,'$'
    
    msgVittoria db " ha vinto questa mano!",13,10,'$'
    
    msgPuntiX db "Punti X: $"
    msgPuntiO db "Punti O: $"
    msgPareggiTot db "Pareggi: $"

    ; buffer per leggere da tastiera con int 21h funzione 0Ah
    ; il primo byte e' la lunghezza max, il secondo quanti ha letto
    buffer db 3, 0, 0, 0, 0

.code
inizio:
    mov ax, @data
    mov ds, ax

    ; stampo il benvenuto
    call mostraBenvenuto
    call pulisciSchermo

; ciclo principale, qui si rigioca
partita:
    call azzeraGriglia
    call stampaGriglia

; ciclo interno, una singola mano
gioco:
    ; stampo chi deve giocare
    mov al, turno
    call stampaCarattere
    lea dx, msgTurno
    call stampaStringa

    ; leggo la mossa
    call leggiMossa

    ; aggiorno schermo
    call pulisciSchermo
    call stampaGriglia

    ; controllo se qualcuno ha vinto o pareggio
    mov vince, 0
    call controllaVincita
    cmp vince, 1
    je qualcunoVince
    cmp vince, 2
    je finiscePari

    ; cambio giocatore e continuo
    call cambiaTurno
    jmp gioco

qualcunoVince:
    call gestisciVittoria
    jmp domandaRigioca

finiscePari:
    call gestisciPareggio

domandaRigioca:
    lea dx, chiediRigioca
    call stampaStringa
    call leggiScelta
    cmp al, 1
    je partita

    ; se arrivo qui vuole uscire
    call saluta
    mov ah, 4Ch
    int 21h

; ============================================
; PROCEDURE - qui sotto ho messo tutte le funzioni
; ============================================

; stampa il messaggio iniziale
mostraBenvenuto proc
    push dx
    lea dx, benvenuto
    call stampaStringa
    call aspettaTasto
    pop dx
    ret
mostraBenvenuto endp

; azzera la griglia rimettendo i numeri 1-9
azzeraGriglia proc
    push ax
    push bx
    push cx
    push si
    push di

    mov cx, 9          ; ci sono 9 caselle
    mov si, 0
    mov bl, '1'        ; inizio dal numero 1

cicloAzzera:
    mov al, bl
    push bx
    mov bx, si
    shl bx, 1          ; moltiplico per 2 perche dw
    mov di, posizioni[bx]
    pop bx
    mov griglia[di], al
    inc bl
    inc si
    loop cicloAzzera

    pop di
    pop si
    pop cx
    pop bx
    pop ax
    ret
azzeraGriglia endp

; stampa la griglia a schermo
stampaGriglia proc
    push dx
    lea dx, griglia
    call stampaStringa
    pop dx
    ret
stampaGriglia endp

; legge la mossa del giocatore e la valida
leggiMossa proc
    push ax
    push bx
    push dx
    push di

richiedi:
    call leggiNumero
    cmp al, 0
    je nonVaBene

    ; converto in indice 0-based
    mov bl, al
    dec bl
    xor bh, bh
    shl bx, 1
    mov di, posizioni[bx]

    ; controllo che la casella sia libera (deve avere un numero 1-9)
    mov al, griglia[di]
    cmp al, '1'
    jb occupata
    cmp al, '9'
    ja occupata
    jmp mettiSegno

nonVaBene:
    lea dx, msgErrore
    call stampaStringa
    jmp richiedi

occupata:
    lea dx, msgErrore
    call stampaStringa
    jmp richiedi

mettiSegno:
    mov al, turno
    mov griglia[di], al

    pop di
    pop dx
    pop bx
    pop ax
    ret
leggiMossa endp

; controlla se c'e' una vittoria o pareggio
controllaVincita proc
    push ax
    push bx
    push si
    push di

    mov bl, turno
    mov vince, 0

    ; --- controllo le 3 righe ---
    mov si, 0
    call check3
    cmp vince, 1
    je finitoControllo

    mov si, 6
    call check3
    cmp vince, 1
    je finitoControllo

    mov si, 12
    call check3
    cmp vince, 1
    je finitoControllo

    ; --- controllo le 3 colonne ---
    call checkCol1
    cmp vince, 1
    je finitoControllo

    call checkCol2
    cmp vince, 1
    je finitoControllo

    call checkCol3
    cmp vince, 1
    je finitoControllo

    ; --- controllo le 2 diagonali ---
    call checkDia1
    cmp vince, 1
    je finitoControllo

    call checkDia2
    cmp vince, 1
    je finitoControllo

    ; se nessuno ha vinto, controllo il pareggio
    call checkPari

finitoControllo:
    pop di
    pop si
    pop bx
    pop ax
    ret
controllaVincita endp

; controlla 3 caselle consecutive (serve per le righe)
check3 proc
    push ax
    push di

    mov di, posizioni[si]
    mov al, griglia[di]
    cmp al, bl
    jne nonVinceQui

    mov di, posizioni[si+2]
    mov al, griglia[di]
    cmp al, bl
    jne nonVinceQui

    mov di, posizioni[si+4]
    mov al, griglia[di]
    cmp al, bl
    jne nonVinceQui

    mov vince, 1
    jmp fineCheck3

nonVinceQui:
fineCheck3:
    pop di
    pop ax
    ret
check3 endp

; colonna 1: caselle 1, 4, 7 (indici 0, 6, 12)
checkCol1 proc
    push ax
    push di

    mov di, posizioni[0]
    mov al, griglia[di]
    cmp al, bl
    jne noCol1
    mov di, posizioni[6]
    mov al, griglia[di]
    cmp al, bl
    jne noCol1
    mov di, posizioni[12]
    mov al, griglia[di]
    cmp al, bl
    jne noCol1
    mov vince, 1
noCol1:
    pop di
    pop ax
    ret
checkCol1 endp

; colonna 2: caselle 2, 5, 8 (indici 2, 8, 14)
checkCol2 proc
    push ax
    push di

    mov di, posizioni[2]
    mov al, griglia[di]
    cmp al, bl
    jne noCol2
    mov di, posizioni[8]
    mov al, griglia[di]
    cmp al, bl
    jne noCol2
    mov di, posizioni[14]
    mov al, griglia[di]
    cmp al, bl
    jne noCol2
    mov vince, 1
noCol2:
    pop di
    pop ax
    ret
checkCol2 endp

; colonna 3: caselle 3, 6, 9 (indici 4, 10, 16)
checkCol3 proc
    push ax
    push di

    mov di, posizioni[4]
    mov al, griglia[di]
    cmp al, bl
    jne noCol3
    mov di, posizioni[10]
    mov al, griglia[di]
    cmp al, bl
    jne noCol3
    mov di, posizioni[16]
    mov al, griglia[di]
    cmp al, bl
    jne noCol3
    mov vince, 1
noCol3:
    pop di
    pop ax
    ret
checkCol3 endp

; diagonale principale: 1, 5, 9
checkDia1 proc
    push ax
    push di

    mov di, posizioni[0]
    mov al, griglia[di]
    cmp al, bl
    jne noDia1
    mov di, posizioni[8]
    mov al, griglia[di]
    cmp al, bl
    jne noDia1
    mov di, posizioni[16]
    mov al, griglia[di]
    cmp al, bl
    jne noDia1
    mov vince, 1
noDia1:
    pop di
    pop ax
    ret
checkDia1 endp

; diagonale secondaria: 3, 5, 7
checkDia2 proc
    push ax
    push di

    mov di, posizioni[4]
    mov al, griglia[di]
    cmp al, bl
    jne noDia2
    mov di, posizioni[8]
    mov al, griglia[di]
    cmp al, bl
    jne noDia2
    mov di, posizioni[12]
    mov al, griglia[di]
    cmp al, bl
    jne noDia2
    mov vince, 1
noDia2:
    pop di
    pop ax
    ret
checkDia2 endp

; controlla se e' finita in parita (nessun numero rimasto)
checkPari proc
    push ax
    push cx
    push si
    push di

    mov cx, 9
    mov si, 0

cicloPari:
    mov di, posizioni[si]
    mov al, griglia[di]
    cmp al, '1'
    jb nonPari
    cmp al, '9'
    ja nonPari
    add si, 2
    loop cicloPari

    ; se arrivo qui tutte le caselle sono piene
    mov vince, 2
    jmp finitoPari

nonPari:
    mov vince, 0

finitoPari:
    pop di
    pop si
    pop cx
    pop ax
    ret
checkPari endp

; quando qualcuno vince, aggiorno i punti e stampo
gestisciVittoria proc
    push ax
    push dx

    ; stampo chi ha vinto
    mov al, turno
    call stampaCarattere
    lea dx, msgVittoria
    call stampaStringa

    ; aggiorno il contatore
    cmp turno, 'X'
    je puntoX
    cmp turno, 'O'
    je puntoO
    jmp mostraPunteggio

puntoX:
    inc puntiX
    jmp mostraPunteggio

puntoO:
    inc puntiO

mostraPunteggio:
    ; stampo i punti di X
    lea dx, msgPuntiX
    call stampaStringa
    mov al, puntiX
    call stampaNumero

    ; stampo i punti di O
    lea dx, msgPuntiO
    call stampaStringa
    mov al, puntiO
    call stampaNumero

    ; stampo i pareggi
    lea dx, msgPareggiTot
    call stampaStringa
    mov al, pari
    call stampaNumero

    pop dx
    pop ax
    ret
gestisciVittoria endp

; gestisce il pareggio
gestisciPareggio proc
    push ax
    push dx

    lea dx, msgPareggio
    call stampaStringa

    inc pari

    ; mostro comunque i punteggi
    lea dx, msgPuntiX
    call stampaStringa
    mov al, puntiX
    call stampaNumero

    lea dx, msgPuntiO
    call stampaStringa
    mov al, puntiO
    call stampaNumero

    lea dx, msgPareggiTot
    call stampaStringa
    mov al, pari
    call stampaNumero

    pop dx
    pop ax
    ret
gestisciPareggio endp

; cambia il turno da X a O o viceversa
cambiaTurno proc
    push ax

    mov al, turno
    cmp al, 'X'
    je mettiO
    cmp al, 'O'
    je mettiX
    jmp fineTurno

mettiO:
    mov turno, 'O'
    jmp fineTurno

mettiX:
    mov turno, 'X'

fineTurno:
    pop ax
    ret
cambiaTurno endp

; saluta alla fine
saluta proc
    push dx
    lea dx, arrivederci
    call stampaStringa
    pop dx
    ret
saluta endp

; ============================================
; PROCEDURE DI UTILITA (le ho messe qua sotto)
; ============================================

; stampa una stringa che sta in DX
stampaStringa proc
    push ax
    mov ah, 09h
    int 21h
    pop ax
    ret
stampaStringa endp

; stampa un singolo carattere che sta in AL
stampaCarattere proc
    push ax
    push dx
    mov dl, al
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    ret
stampaCarattere endp

; va a capo (13,10)
aCapo proc
    push ax
    push dx
    mov dl, 13
    mov ah, 02h
    int 21h
    mov dl, 10
    mov ah, 02h
    int 21h
    pop dx
    pop ax
    ret
aCapo endp

; stampa un numero da 0 a 255 che sta in AL
stampaNumero proc
    push ax
    push bx
    push cx
    push dx

    xor cx, cx
    mov bl, 10

    cmp al, 0
    jne converti

    ; se e' zero stampo subito 0
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp fineNumero

converti:
    xor ah, ah
    div bl
    push ax
    inc cx
    cmp al, 0
    jne converti

stampaCifra:
    pop ax
    mov dl, ah
    add dl, '0'
    mov ah, 02h
    int 21h
    loop stampaCifra

fineNumero:
    call aCapo

    pop dx
    pop cx
    pop bx
    pop ax
    ret
stampaNumero endp

; legge un numero da 1 a 9, ritorna in AL (0 se sbagliato)
leggiNumero proc
    push bx
    push dx

leggiAncora:
    mov al, 2
    mov buffer, al
    mov al, 0
    mov buffer+1, al

    lea dx, buffer
    mov ah, 0Ah
    int 21h

    call aCapo

    ; controllo che abbia scritto solo 1 carattere
    mov al, buffer+1
    cmp al, 1
    jne numeroSbagliato

    mov al, buffer+2
    cmp al, '1'
    jb numeroSbagliato
    cmp al, '9'
    ja numeroSbagliato

    sub al, '0'    ; converto da ASCII a numero
    jmp fineNumeroLetto

numeroSbagliato:
    mov al, 0

fineNumeroLetto:
    pop dx
    pop bx
    ret
leggiNumero endp

; legge s/n, ritorna AL=1 per si, AL=0 per no
leggiScelta proc
    push bx
    push dx

leggiSceltaAncora:
    mov al, 2
    mov buffer, al
    mov al, 0
    mov buffer+1, al

    lea dx, buffer
    mov ah, 0Ah
    int 21h

    call aCapo

    mov al, buffer+1
    cmp al, 1
    jne sceltaNo

    mov al, buffer+2
    cmp al, 's'
    je sceltaSi
    cmp al, 'S'
    je sceltaSi

sceltaNo:
    mov al, 0
    jmp fineScelta

sceltaSi:
    mov al, 1

fineScelta:
    pop dx
    pop bx
    ret
leggiScelta endp

; aspetta che l'utente premi un tasto
aspettaTasto proc
    push ax
    mov ah, 01h
    int 21h
    pop ax
    ret
aspettaTasto endp

; pulisce lo schermo con interrupt del BIOS
pulisciSchermo proc
    push ax
    push bx
    push cx
    push dx

    mov ax, 0600h
    mov bh, 07h
    mov cx, 0000h
    mov dx, 184Fh
    int 10h

    ; riporto il cursore in alto a sinistra
    mov ah, 02h
    mov bh, 00h
    mov dx, 0000h
    int 10h

    pop dx
    pop cx
    pop bx
    pop ax
    ret
pulisciSchermo endp

end inizio




