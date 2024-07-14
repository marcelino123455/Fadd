module equal (
    input [31:0] a,
    input [31:0] b,
    output y,
    output y2
);

    assign y = (a == b);
    assign y2 = (a[31:3] == b[31:3]);

endmodule
