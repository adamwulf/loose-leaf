attribute vec4 position;
attribute vec4 inputTextureCoordinate;

varying vec2 textureCoordinate;

uniform mat4 MVP;

void main()
{
    gl_Position = MVP * position;
    textureCoordinate = inputTextureCoordinate.xy;
}
