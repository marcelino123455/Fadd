`timescale 1ns / 1ps
module faddV(a,b,y);
    input [31:0] a;
    input [31:0] b;
    output reg [31:0] y;
    
    wire s1, s2;
    wire [7:0] e1, e2;
    wire [23:0] m1, m2;
    //Asignación de las partes:
    //Signos
    assign s1 = a[31];
    assign s2 = b[31];
    //Exponentes
    assign e1 = a[30:23];
    assign e2 = b[30:23];
    //Mantisas
    assign m1[22:0] = a[22:0];
    assign m2[22:0] = b[22:0];
    
    //1) El exponente mayor 
    wire em; //Es 1 si e1 es mayor caso contrario toma 0
    assign em = (e1 > e2);
    wire ee; //Expos iguales
    assign ee = (e1 == e2);
    wire se;// Signos iguales
    assign se = (s1 == s2);
    
   
    // Calculo el valor que debo shitear
    reg [7:0] q; //valor de shifteo
    always @* begin
        if (em) begin
            // Calculo q = e1 - e2
            q = e1 - e2;
        end else begin
            // Calculo q = e2 - e1
            q = e2 - e1;
        end
    end
    
    //Añado el bit implicito a las mantisas
    wire b1;
    assign b1 =1;
    assign m1[23] = b1;
    assign m2[23] = b1;
    //Uso el valor de q para shiftear el numero de posicions a la mantisa con el exponente menor
    wire round; //---IMPORTANTEEE--- o el redondeo positivo 

    reg [23:0] shifted_m1, shifted_m2;
    reg [24:0] mantisa_for_round; //Mantisa q nos permite ver el redondeo
    always @* begin
        if (em) begin
            // Desplazar m2 a la posición de m1 (q posiciones a la izquierda si q > 0)
            shifted_m2 = (q > 0) ? (m2 >> q) : m2;//Arreglando
            shifted_m1 = m1; // m1 ya está en la posición correcta
            mantisa_for_round = (q > 0) ? (m2 >> q) : m2;
        end else begin
            // Desplazar m1 a la posición de m2 (|q| posiciones a la izquierda si q < 0)
            shifted_m1 = (q > 0) ? (m1 >> q) : m1; //Siempre hago shifteo del menor al mayor
            shifted_m2 = m2; // m2 ya está en la posición correcta
            mantisa_for_round = (q > 0) ? (m1 >> q) : m1; 
            
        end
    end
    wire [24:0]m_R;
    wire [7:0]exp_R;
    wire roundn;//Para ver si se usa el redondeo negativo
    sub subtuki( .m1(m1),.m2(m2),.q(q),.em(em),.ee(ee),.e1(e1),.e2(e2), .m_R(m_R), .round(roundn), .exp_R(exp_R));
    
    //BIT PARA REDONDEO: 
    assign round = (se?mantisa_for_round[0]:roundn);
    //Si son signos iguales redondeo de suma, sino el de resta
    
    
    
    //Sumar las mantisas adecuadamente
    reg [24:0] mantisaS; //Ahora es de 25 bits, para el caso de overflow de mantisas 
    always @* 
    begin
        if (se) begin
            mantisaS = shifted_m1 + shifted_m2;  // signos iguales
        end else begin
            mantisaS = m_R;  // signos diferentes
        end
    end
    
    //"Pequeño" bucle apra reducir la cantidad de ifs:
    reg [7:0]exp;
 
    always @* begin
        if (em) //e1>e2
            if (se)
                exp = e1;
            else // Caso de resta
                exp = exp_R;
                
        else //e1<=e2
        begin
            if (ee) //e1 == e2
                if (se)
                    exp = e1+1;
                else // Caso de resta
                    exp = exp_R;
            else //e1<e2
                if (se)
                    exp = e2;
                else // Caso de resta
                    exp = exp_R;
        end
    end
    
    
    
    //Aqui lo redondeo
     always @* begin
        if (em) //e1>e2
            begin
                if(!mantisaS[24])
                    y = {s1, exp, round ? {mantisaS[22:0]+1'b1} : { mantisaS[22:0]}};
                else
                    y = {s1, exp, round ? {mantisaS[23:1]+1'b1} : { mantisaS[23:1]}};
            end 
        else //e1<=e2
        begin
            if (ee) //e1 == e2
                begin
                    if(!mantisaS[24])
                        y = {s1, exp, round ? {mantisaS[22:0]+1'b1} : { mantisaS[22:0]}};

                    else
                        y = {s1, exp, round ? {mantisaS[23:1]+1'b1} : { mantisaS[23:1]}};

                end 
            else //e1<e2
                begin
                    if(!mantisaS[24])
                        y = {s2, exp, round ? {mantisaS[22:0]+1'b1} : { mantisaS[22:0]}};
                    else
                        y = {s2, exp, round ? {mantisaS[23:1]+1'b1}: { mantisaS[23:1]}};
                end 
                
               
        end
    end
    
endmodule
