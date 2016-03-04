varying highp vec2 textureCoordinate;

uniform sampler2D texture;

void main()
{
    highp vec4 color = texture2D(texture, textureCoordinate);
    if(color.a == 0.0)
    {
        discard;
    }
    gl_FragColor = color;
}