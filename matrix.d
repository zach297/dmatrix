/*
Copyright (C) 2012 Zach Reizner (zach297@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

import std.algorithm;
import std.math;
import std.random;
import std.stdio;
import vector;

struct Matrix(T, size_t S=4) if (S>=1)
{
    private alias Matrix!(T, S) mat;
    private alias Vector!(T, S) vec;

    private T[S][S] A;

    this(T[S*S] V ...)
    {
        foreach(x; 0..S)
            foreach(y; 0..S)
                A[x][y] = V[x*S+y];
    }
    this(T[S*S] V)
    {
        foreach(x; 0..S)
            foreach(y; 0..S)
                A[x][y] = V[x*S+y];
    }

    static mat opCall(T[S*S] V)
    {
        mat A;
        foreach(x; 0..S)
            foreach(y; 0..S)
                A[x,y] = V[x*S+y];
        return A;
    }

    @property T[] array()
    {
        T[] V = new T[S*S];
        foreach(x; 0..S)
            foreach(y; 0..S)
                V[x*S+y] = A[x][y];
        return V;
    }
    @property T* ptr() { return A[0].ptr; }

    T opIndex(size_t x, size_t y) { return A[x][y]; }
    T opIndexAssign(T v, size_t x, size_t y)
    {
        return A[x][y] = v;
    }

    ref mat opOpAssign(string op)(T B)
    {
        foreach(x; 0..S)
            foreach(y; 0..S)
                mixin("A[x][y] " ~ op ~ "= B;");
        return this;
    }

    ref mat opOpAssign(string op)(mat B)
    {
        static if (op == "*")
        {
            A = (this * B).A;
            return this;
        }

    }

    mat opBinary(string op)(T B)
    {
        mat R;
        foreach(x; 0..S)
            foreach(y; 0..S)
                mixin("R.A[x][y] = A[x][y] " ~ op ~ " B;");
        return R;
    }

    vec opBinary(string op)(vec B)
    {
        static if (op == "*")
        {
            return multiply(B);
        }
    }

    mat opBinary(string op)(mat B)
    {
        static if (op == "*")
        {
            return multiply(B);
        }
    }

    void zero()
    {
        foreach(i; 0..S)
            A[i][] = 0;
    }

    void identity()
    {
        foreach(x; 0..S)
            foreach(y; 0..S)
                A[x][y] = (x==y) ? 1 : 0;
    }


    vec multiply(vec B)
    {
        vec R;
        foreach(y; 0..S)
        {
            foreach(x; 0..S)
                R[y] += A[x][y] * B[x];
        }
        return R;
    }

    mat multiply(mat B)
    {
        mat R;
        foreach(x; 0..S)
        {
            foreach(y; 0..S)
            {
                T[S] V;
                foreach (i; 0..S)
                    V[i] = A[i][y] * B.A[x][i];
                R.A[x][y] = reduce!"a+b"(V);
            }
        }
        return R;
    }

    void print()
    {
        foreach(y; 0..S)
        {
            foreach(x; 0..S)
            {
                write(A[x][y], ' ');
            }
            writeln();
        }
    }

    static Matrix!(T,4) createPerspective(real aspect, real fov, real near, real far)
    {
        Matrix!(T,4) A;
        A.zero();
        real f = 1/tan(fov / 2);
        real diff = near - far;
        A[0,0] = f / aspect;
        A[1,1] = f;
        A[2,2] = (near + far) / diff;
        A[3,2] = (2 * near * far) / diff;
        A[2,3] = -1;
        return A;
    }

    static Matrix!(T,4) createViewing(vec3 position, vec3 forward, vec3 up)
    {
        alias forward f;
        alias position p;
        forward.normalize();
        up.normalize();
        vec3 s = vec3.cross(f, up);
        vec3 u = vec3.cross(s, f);
        Matrix!(T,4) A;
        A.identity();
        A[0,0] = s[0];
        A[1,0] = s[1];
        A[2,0] = s[2];
        A[0,1] = u[0];
        A[1,1] = u[1];
        A[2,1] = u[2];
        A[0,2] = -f[0];
        A[1,2] = -f[1];
        A[2,2] = -f[2];
        A[3,0] = p[0];
        A[3,1] = p[1];
        A[3,2] = p[2];
        return A;
    }

    static mat createZero()
    {
        mat A;
        A.zero();
        return A;
    }

    static mat createIdentity()
    {
        mat A;
        A.identity();
        return A;
    }

    static mat createRandom()
    {
        mat A;
        foreach(x; 0..S)
        {
            foreach(y; 0..S)
            {
                A[x,y] = uniform(-1.0, 1.0);
            }
        }
        return A;
    }

    static mat createTranslation(size_t Q)(Vector!(T,Q) translation) if (Q==S-1)
    {
        mat ret = mat.createIdentity();

        foreach(y; 0..Q)
            ret.A[$-1][y] = translation[y];

        return ret;
    }

    static mat createUniformScale(T scale)
    {
        mat ret = mat.createIdentity();

        foreach(y; 0..S)
            ret.A[y][y] = scale;

        return ret;
    }

    static mat createScale(size_t Q)(Vector!(T,Q) scale) if (Q==S-1)
    {
        mat ret = mat.createIdentity();

        foreach(y; 0..Q)
            ret.A[y][y] = scale[y];

        return ret;
    }

    static Matrix!(T,4) createRotation()
    {
        Matrix!(T,4) rot = Matrix!(T,4).createIdentity();



        return rot;
    }

}

alias Matrix!(float,2) mat2;
alias Matrix!(float,3) mat3;
alias Matrix!(float,4) mat4;

unittest
{
    // Test the zero matrix.
    mat4 zeroMatrix;
    zeroMatrix.zero();
    assert(!canFind!"a != b"(zeroMatrix.array, 0));

    // Test the identity matrix.
    mat4 A = mat4.createIdentity();
    mat4 B = mat4.createRandom();
    assert(B == A*B);

    // Test that the matrix is arranged in column major order.
    assert(B[0, 1] == B.ptr[1]);

    // Test the perspective matrix.
    mat4 P = mat4.createPerspective(4.0/3.0, PI_4, 0.1, 100);
    assert(equal!"abs(a-b) < float.epsilon"(P.array, [1.8106601238250732, 0, 0, 0, 0, 2.4142136573791504, 0, 0, 0, 0, -1.0020020008087158, -1, 0, 0, -0.20020020008087158, 0]));

    // Test a basic matrix multiplication.
    mat4 D = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    mat4 E = [100, 99, 98, 97, 96, 95, 94, 93, 92, 91, 90, 89, 88, 87, 86, 85];
    assert((D*E).array == [2344, 2738, 3132, 3526, 2248, 2626, 3004, 3382, 2152, 2514, 2876, 3238, 2056, 2402, 2748, 3094]);
    D *= A;
    assert(D.array == [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);

    // Test multiply by a scalar.
    assert((D*2).array == [0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30]);

    // Test add and assign.
    mat2 F = [-1, 1, -2, 2];
    F += 2;
    assert(F.array == [1, 3, 0, 4]);

    // Test a matrix multiply with a vector.
    vec4 G = [-4, 4, 4, 4];
    assert((D*G).array == [96,104,112,120]);
}
