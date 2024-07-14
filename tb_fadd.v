`timescale 1ns / 1ps
module tb_fadd;
    // Entradas
    reg [31:0] a;
    reg [31:0] b;
    // Salidas
    wire [31:0] y4;
    wire total_e;
    wire total_3;
    
    
    //TESTES RESULTS
    reg [31:0] test;

    
    faddV tuki (
        .a(a), 
        .b(b), 
        .y(y4)
    );
    
    equal equaltuki(.a(test), .b(y4), .y(total_e), .y2(total_3));

    // Inicializar los valores de prueba
    initial begin
        a = 32'b00111111110000000000000000000000; //1.5
        b = 32'b01000000100100000000000000000000; //4.5 
        test= 32'b01000000110000000000000000000000;//6
        //Resultado esperado 6
        #10; 
        a = 32'b01000000011100011100011101111000; //3.7777996063232
        b = 32'b01000000010010010000111001010110; //3.1414999961853 
        test= 32'b01000000110111010110101011100111;//6.919299602508544921875

        //Resultado = 6.9193
        #10; 
        a = 32'b00111111101111001100110011001101; //1.475
        b = 32'b00111010101000010011011111110100; //0.00123 
        test= 32'b00111111101111001111010100011011;//1.47623002529144287109375
        //Resultado = 1.47623   
        #10; 
        
        b = 32'b00111111101111001100110011001101; //1.475
        a = 32'b00111010101000010011011111110100; //0.00123
        test= 32'b00111111101111001111010100011011;//1.47623002529144287109375 
        
        //Resultado = 1.47623   
        #10; 
        
        a = 32'b00111111111100101101101110100011; //1.8973278328
        b = 32'b01000100001001101010101111110110; //666.686878
        test= 32'b01000100001001110010010101100100;//668.584228515625 
        
        //PRUEBA PARA RESTAS: 
        #10; 
        
        a = 32'b10111111101111001100110011001101; //-1.475
        b = 32'b00111010101000010011011111110100; //0.00123
        test= 32'b10111111101111001010010001111111;//-1.47377002239227294921875
        #10; 
        
        
        
        
       
        
        
        $finish;
    end
endmodule