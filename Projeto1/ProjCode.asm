; mudar origem para 00, executado quando o processador reinicia
org 0h
; pulo para funcao main
jmp main

org 32h

main:
    ; Inicializar registradores e estado inicial
    MOV R0, #0       ; Registrador para contagem de 0 a 9
    MOV R1, #4       ; Usado para a contagem de 1s
    MOV P1, #11111111b ; Display desligado inicialmente

    ; Loop principal - aguardar início da contagem
wait_for_start:
    ; Verificar se SW0 ou SW1 está pressionado para iniciar
    JB P2.0, start_with_250ms
    JB P2.1, start_with_1s
    ; Continuar aguardando
    LJMP wait_for_start

; Iniciar contagem com delay de 0,25s
start_with_250ms:
    ACALL delay_250ms
    ACALL pulse_accordingly
    ; Verificar se SW1 foi pressionado para mudar para 1s
    JB P2.1, start_with_1s
    LJMP start_with_250ms

; Iniciar contagem com delay de 1s
start_with_1s:
    ACALL delay_1s
    ACALL pulse_accordingly
    ; Verificar se SW0 foi pressionado para mudar para 0,25s
    JB P2.0, start_with_250ms
    LJMP start_with_1s

; Função de delay de aproximadamente 250ms
delay_250ms:
    MOV R2, #10      ; Loop externo, 10 iterações
delay_250ms_loop1:
    MOV R3, #50      ; Loop interno, 50 iterações
delay_250ms_loop2:
    MOV R4, #200     ; Ajustar para atingir 250ms com ciclos
delay_250ms_loop3:
    DJNZ R4, delay_250ms_loop3 ; Decrementa até zero
    DJNZ R3, delay_250ms_loop2 ; Repete o loop interno
    DJNZ R2, delay_250ms_loop1 ; Repete o loop externo
    RET               ; Retorna quando terminar o delay

; Função de delay de aproximadamente 1s
delay_1s:
    MOV R2, #40      ; Loop externo, 40 iterações para 1s
delay_1s_loop1:
    MOV R3, #50      ; Loop interno
delay_1s_loop2:
    MOV R4, #200     ; Ajuste de tempo
delay_1s_loop3:
    DJNZ R4, delay_1s_loop3
    DJNZ R3, delay_1s_loop2
    DJNZ R2, delay_1s_loop1
    RET

; Função para incrementar r0 e imprimir seu valor no display de 7 segmentos
; automaticamente reinicia r0 para 0 quando seu valor atinge 10
increment_and_print:
    ; Incrementar r0
    INC R0
    ; Comparar com 10 para decidir se deve reiniciar
    CJNE R0, #0Ah, not_exceeded
    ; Se r0 = 10, reiniciar para r0 = 0
    MOV R0, #0
not_exceeded:
    ; Imprimir para display de 7 segmentos
    ACALL out_7seg
    ; Encerrar função
    RET

; Função que incrementa e imprime de acordo com a chave pressionada
pulse_accordingly:
    ; Verificar se SW0 está pressionado
    JB P2.0, increment_and_print
    ; Verificar se SW1 está pressionado
    JB P2.1, increment_if_slow_mode
    ; Caso nenhuma chave esteja pressionada, apenas retorna
    RET

increment_if_slow_mode:
    ; Incrementar apenas se r1 = 0
    DJNZ R1, skip_increment
    ; Caso r1 seja 0, reiniciar para 4 e chamar increment_and_print
    MOV R1, #4
    ACALL increment_and_print
skip_increment:
    RET

; Função que imprime o valor de r0 no display de 7 segmentos
out_7seg:
    CJNE R0, #0, out_7seg_1
    MOV P1, #11000000b
    RET
out_7seg_1:
    CJNE R0, #1, out_7seg_2
    MOV P1, #11111001b
    RET
out_7seg_2:
    CJNE R0, #2, out_7seg_3
    MOV P1, #10100100b
    RET
out_7seg_3:
    CJNE R0, #3, out_7seg_4
    MOV P1, #10110000b
    RET
out_7seg_4:
    CJNE R0, #4, out_7seg_5
    MOV P1, #10011001b
    RET
out_7seg_5:
    CJNE R0, #5, out_7seg_6
    MOV P1, #10010010b
    RET
out_7seg_6:
    CJNE R0, #6, out_7seg_7
    MOV P1, #10000010b
    RET
out_7seg_7:
    CJNE R0, #7, out_7seg_8
    MOV P1, #11111000b
    RET
out_7seg_8:
    CJNE R0, #8, out_7seg_9
    MOV P1, #10000000b
    RET
out_7seg_9:
    CJNE R0, #9, out_7seg_big
    MOV P1, #10010000b
    RET
out_7seg_big:
    MOV P1, #11111111b
    RET
