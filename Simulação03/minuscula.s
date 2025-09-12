    .section .data
buffer: .space 128      # Aloca 128 bytes para o buffer de leitura.

    .section .text
    .globl _start       # Torna o rótulo _start global.
_start:
    # Chama a syscall para ler dados da entrada padrão (read).
    # read(fd=0, buffer, count=128)
    li a7, 63             # Carrega o número da syscall 'read' (63) no registrador a7.
    li a0, 0              # Define o file descriptor (fd) como 0 (entrada padrão - stdin).
    la a1, buffer         # Carrega o endereço do 'buffer' no a1 (destino dos dados).
    li a2, 128            # Define o tamanho máximo de bytes a serem lidos no a2.
    ecall                 # Executa a syscall. O número de bytes lidos é retornado em a0.
    mv s0, a0             # Move o número de bytes lidos de a0 para s0, para preservá-lo.

    # Converte letras A–Z em minúsculas.
    la t1, buffer         # Carrega o endereço do 'buffer' no t1 (ponteiro para a string).
    mv t0, s0             # Inicializa o contador de bytes (t0) com o número total de bytes lidos (s0).

loop:
    # Início do loop principal.
    beqz t0, done         # Se o contador (t0) for zero, todos os bytes foram processados. Salta para 'done'.
    lbu t2, 0(t1)         # Lê o próximo byte sem sinal (caractere) da memória para t2.
    
    # Verifica se o caractere está no intervalo de 'A' a 'Z'.
    li t3, 'A'            # Carrega o valor ASCII de 'A' (0x41).
    blt t2, t3, skip      # Se o caractere for menor que 'A', ele não é uma letra maiúscula. Salta para 'skip'.
    li t3, 'Z'            # Carrega o valor ASCII de 'Z' (0x5A).
    bgt t2, t3, skip      # Se o caractere for maior que 'Z', ele não é uma letra maiúscula. Salta para 'skip'.
    
    # Converte a letra maiúscula para minúscula.
    ori t2, t2, 0x20      # Realiza a operação OR bit a bit com 0x20 (32). Isso força o bit 5 a 1,
                          # convertendo a letra para minúscula de forma eficiente.
    sb t2, 0(t1)          # Salva o caractere modificado de volta na memória.
skip:
    # Avança para o próximo caractere.
    addi t1, t1, 1        # Incrementa o ponteiro (t1) para o próximo byte.
    addi t0, t0, -1       # Decrementa o contador de bytes (t0).
    j loop                # Salta de volta para o início do loop.

done:
    # Chama a syscall para escrever a string modificada na saída padrão (write).
    # write(fd=1, buffer, count=nbytes)
    li a7, 64             # Carrega o número da syscall 'write' (64) em a7.
    li a0, 1              # Define o file descriptor como 1 (saída padrão - stdout).
    la a1, buffer         # Carrega o endereço do 'buffer' (a string modificada) em a1.
    mv a2, s0             # Usa o número original de bytes lidos (s0) para o tamanho da escrita.
    ecall                 # Executa a syscall.
    
    # Encerra o programa.
    # exit(status=0)
    li a7, 93             # Carrega o número da syscall 'exit' (93) em a7.
    li a0, 0              # Define o status de saída como 0 (sucesso).
    ecall                 # Executa a syscall.
