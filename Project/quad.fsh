varying highp vec2 textureCoordinate;

uniform sampler2D videoFrame;

void main()
{
    gl_FragColor = texture2D(videoFrame, textureCoordinate);
}