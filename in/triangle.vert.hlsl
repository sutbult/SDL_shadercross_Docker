struct Input {
    uint VertexIndex : SV_VertexID;
};

struct Output {
    float4 Position : SV_Position;
};

Output main(Input input) {
    float2 position;

    if(input.VertexIndex == 0) {
        position = float2(-1, -1);
    }
    else if(input.VertexIndex == 1) {
        position = float2(+1, -1);
    }
    else if(input.VertexIndex == 2) {
        position = float2( 0, +1);
    }

    Output output;
    output.Position = float4(position, 0, 1);
    return output;
}
