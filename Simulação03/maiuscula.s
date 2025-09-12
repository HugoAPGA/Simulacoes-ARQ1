    .section .data
buffer: .space 128      # Aloca 128 bytes de espaço para o buffer de leitura.

    .section .text
    .globl _start       # Define o ponto de entrada principal do programa.
_start:
    # Chama a syscall para ler dados da entrada padrão (read).
    # read(fd=0, buffer, count=128)
    li a7, 63             # Carrega o número da syscall 'read' no registrador a7.
    li a0, 0              # Define o descritor de arquivo como 0 para a entrada padrão (stdin).
    la a1, buffer         # Carrega o endereço do 'buffer' no a1, o destino dos dados lidos.
    li a2, 128            # Define o tamanho máximo de bytes a serem lidos no a2.
    ecall                 # Executa a syscall. O número de bytes lidos é retornado em a0.
    mv s0, a0             # Move o número de bytes lidos de a0 para s0 para preservá-lo.

    # Configura os registradores para o loop de conversão.
    la t1, buffer         # Carrega o endereço do 'buffer' no t1 (ponteiro de iteração).
    mv t0, s0             # Move o número de bytes lidos para t0 (contador de bytes).

loop:
    # Início do loop principal de iteração sobre a string.
    beqz t0, done         # Se o contador de bytes (t0) for zero, a string foi processada. Salta para 'done'.
    lbu t2, 0(t1)         # Carrega o byte sem sinal do endereço apontado por t1 no t2.
    
    # Verifica se o caractere é uma letra minúscula.
    li t3, 'a'            # Carrega o valor ASCII de 'a' (0x61).
    blt t2, t3, skip      # Se o caractere for menor que 'a', não é uma letra minúscula. Salta para 'skip'.
    li t3, 'z'            # Carrega o valor ASCII de 'z' (0x7A).
    bgt t2, t3, skip      # Se o caractere for maior que 'z', não é uma letra minúscula. Salta para 'skip'.
    
    # Converte a letra minúscula para maiúscula.
    andi t2, t2, 0xDF     # Realiza a operação AND bit a bit com 0xDF (11011111b). Isso limpa o bit 5,
                          # convertendo a letra para maiúscula.
    sb t2, 0(t1)          # Salva o caractere modificado de volta na memória no endereço de t1.
skip:
    # Avança para o próximo caractere.
    addi t1, t1, 1        # Incrementa o ponteiro de iteração (t1).
    addi t0, t0, -1       # Decrementa o contador de bytes (t0).
    j loop                # Salta incondicionalmente de volta para o início do loop.

done:
    # Chama a syscall para escrever a string modificada na saída padrão (write).
    # write(fd=1, buffer, count=s0)
    li a7, 64             # Carrega o número da syscall 'write' em a7.
    li a0, 1              # Define o descritor de arquivo como 1 para a saída padrão (stdout).
    la a1, buffer         # Carrega o endereço do buffer que contém a string modificada.
    mv a2, s0             # Move o número de bytes lidos (s0) para a2, definindo o tamanho a ser escrito.
    ecall                 # Executa a syscall.

    # Encerra o programa.
    # exit(status=0)
    li a7, 93             # Carrega o número da syscall 'exit' em a7.
    li a0, 0              # Define o status de saída como 0 (sucesso).
    ecall                 # Executa a syscall.
