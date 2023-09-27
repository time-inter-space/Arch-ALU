module Add(
    input [31 : 0] a,
    input [31 : 0] b,
    output reg [31 : 0] sum
);
    wire [31 : 0] g = a & b;
    wire [31 : 0] p = a | b;
    reg [31 : 0] c;
    reg [7 : 0] G, P;
    reg g16;
    reg [7 : 0] tmp;
    integer i;
    always @(g, p) begin
        for (i = 0; i < 8; i = i + 1) begin
            G[i] <= g[i << 2 | 3]
                  | p[i << 2 | 3] & g[i << 2 | 2]
                  | p[i << 2 | 3] & p[i << 2 | 2] & g[i << 2 | 1]
                  | p[i << 2 | 3] & p[i << 2 | 2] & p[i << 2 | 1] & g[i << 2];
            P[i] <= p[i << 2 | 3] & p[i << 2 | 2] & p[i << 2 | 1] & p[i << 2];
        end
    end
    always @(G, P) g16 = G[3] | P[3] & G[2] | P[3] & P[2] & G[1] | P[3] & P[2] & P[1] & G[0];
    always @(g16) begin
        tmp[0] <= 0;
        tmp[1] <= G[0];
        tmp[2] <= G[1] | P[1] & G[0];
        tmp[3] <= G[2] | P[2] & G[1] | P[2] & P[1] & G[0];
        tmp[4] <= g16;
        tmp[5] <= G[4] | P[4] & g16;
        tmp[6] <= G[5] | P[5] & G[4] | P[5] & P[4] & g16;
        tmp[7] <= G[6] | P[6] & G[5] | P[6] & P[5] & G[4] | P[6] & P[5] & P[4] & g16;
    end
    always @(tmp) begin
        for (i = 0; i < 8; i = i + 1) begin
            c[i << 2] <= tmp[i];
            c[i << 2 | 1] <= g[i << 2] | p[i << 2] & tmp[i];
            c[i << 2 | 2] <= g[i << 2 | 1]
                           | p[i << 2 | 1] & g[i << 2]
                           | p[i << 2 | 1] & p[i << 2] & tmp[i];
            c[i << 2 | 3] <= g[i << 2 | 2]
                           | p[i << 2 | 2] & g[i << 2 | 1]
                           | p[i << 2 | 2] & p[i << 2 | 1] & g[i << 2]
                           | p[i << 2 | 2] & p[i << 2 | 1] & p[i << 2] & tmp[i];
        end
    end
    always @(c) sum <= a ^ b ^ c;
endmodule