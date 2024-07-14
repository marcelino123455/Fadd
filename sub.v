`timescale 1ns / 1ps


module sub( m1,m2,q,em, m_R, round);
    
    input [22:0]m1;//mantisa sin bit implicito
    input [22:0]m2; //mantisa sin bit implicito
    
    input [7:0] q;//La cantidad q debo shiftear
    input em; //Si el exponente de m1 es mayor que el de m2
    output [24:0]m_R;
    output round;
    
    //Añado el bit implicito
    wire [31:0]m1b;
    wire [31:0]m2b;
    
    
    //-------
    assign m1b[30:8] = m1[22:0];
    assign m1b[7:0] = 8'b0;
    assign m2b[7:0] = 8'b0;
    assign m2b[30:8] = m2[22:0];
    assign m1b[31]=1'b1;
    assign m2b[31]=1'b1;
    //Ya tengo las mantisas bonitas
    
    //Ahira el shifteo: 
    reg [31:0]shifted_m1b;
    reg [31:0]shifted_m2b;
    
    always @* begin
        if (em) begin
            shifted_m2b = (q > 0) ? (m2b >> q) : m2b;//Arreglando
            shifted_m1b = m1b; // m1 ya está en la posición correcta
        end else begin
            // Desplazar m1 a la posición de m2 (|q| posiciones a la izquierda si q < 0)
            shifted_m1b = (q > 0) ? (m1b >> q) : m1b; //Siempre hago shifteo del menor al mayor
            shifted_m2b = m2b; // m2 ya está en la posición correcta
            
        end
    end
    //Ahora por fin si puedo restar pipi
    reg [31:0]resta;

    always @* begin
        if (em) begin //Para no hacer el swap
            resta = shifted_m1b - shifted_m2b; 
        end else begin // Cuando la otra mantisa es mas grandecita
            resta = shifted_m2b - shifted_m1b;

        end
    end
    //assign m_R[24] = 1'b0;  //Aqui le doy 25 bits para no ajsutar la logica de los condicionales [0] no hay overflow virtual
    assign m_R[24:0] = resta[31:7]; //Aqui le doy 25 bits para no ajsutar la logica de los condicionales
    //Necesito logica para el redondeo por eso
    assign round = resta[5]; //Si el 5 bit es 1 se redondea: 
    
    
endmodule
