    .section .data
buffer: .space 128      # Aloca 128 bytes na memória para o buffer de leitura.

    .section .text
    .globl _start       # Torna o rótulo _start global para que o linker saiba onde o programa começa.
_start:
    # Chama a syscall para ler dados da entrada padrão (read).
    # read(fd=0, buffer, count=128)
    li a7, 63             # Carrega o número da syscall 'read' no registrador a7.
    li a0, 0              # Define o file descriptor (fd) como 0 para a entrada padrão (stdin).
    la a1, buffer         # Carrega o endereço base do 'buffer' no a1 (destino dos dados).
    li a2, 128            # Define o tamanho máximo de bytes a serem lidos no a2.
    ecall                 # Executa a syscall. O número de bytes lidos é retornado em a0.
    mv s0, a0             # Move o número de bytes lidos de a0 para s0, para preservá-lo.

    # Configura os ponteiros para a inversão da string.
    la t1, buffer         # Carrega o endereço do 'buffer' em t1 (ponteiro inicial).
    la t2, buffer         # Carrega o endereço do 'buffer' em t2 (ponteiro final).
    add t2, t2, s0        # Adiciona o número de bytes lidos (s0) ao ponteiro final (t2).
                          # Agora t2 aponta para a posição após o último byte.
    addi t2, t2, -1       # Decrementa t2 em 1 para que ele aponte para o último caractere.

reverse_loop:
    # Loop principal de inversão da string.
    blt t2, t1, done      # Se o ponteiro final (t2) é menor que o inicial (t1), a string foi invertida.
                          # Salta para 'done'.
    lbu t3, 0(t1)         # Carrega o byte sem sinal do endereço apontado por t1 no registrador t3.
    lbu t4, 0(t2)         # Carrega o byte sem sinal do endereço apontado por t2 no registrador t4.
    sb t4, 0(t1)          # Salva o byte de t4 (do final) no endereço de t1 (no início).
    sb t3, 0(t2)          # Salva o byte de t3 (do início) no endereço de t2 (no final).
    addi t1, t1, 1        # Incrementa o ponteiro inicial para o próximo caractere.
    addi t2, t2, -1       # Decrementa o ponteiro final para o caractere anterior.
    j reverse_loop        # Salta incondicionalmente de volta para o início do loop.

done:
    # Chama a syscall para escrever a string invertida na saída padrão (write).
    # write(fd=1, buffer, count=s0)
    li a7, 64             # Carrega o número da syscall 'write' em a7.
    li a0, 1              # Define o file descriptor como 1 para a saída padrão (stdout).
    la a1, buffer         # Carrega o endereço do buffer que contém a string invertida.
    mv a2, s0             # Move o número de bytes lidos (s0) para a2, definindo o tamanho a ser escrito.
    ecall                 # Executa a syscall.

    # Encerra o programa.
    # exit(status=0)
    li a7, 93             # Carrega o número da syscall 'exit' em a7.
    li a0, 0              # Define o status de saída como 0 (sucesso).
    ecall                 # Encerra o programa.
