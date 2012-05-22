/*
Copyright (C) 2012 Zach Reizner (zach297@gmail.com)

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

module dmatrix.vector;

import std.algorithm;
import std.stdio;

struct Vector(T, size_t S=4)
{
    alias Vector!(T,S) vec;
    private T[S] V;
    
    this(T[S] B) { V = B; }
    
    static vec opCall(T[S] V)
    {
        vec U;
        U.V = V;
        return U;
    }
    
    T opIndex(size_t i) { return V[i]; }
    T opIndexAssign(T v, size_t i) { return V[i] = v; }
 
    ref vec opOpAssign(string op)(T B)
    {
        foreach (i; 0..S)
        {
            mixin("V[i] " ~ op ~ "= B;");
        }
        return this;
    }
 
    ref vec opOpAssign(string op)(vec B)
    {
        foreach (i; 0..S)
        {
            mixin("V[i] " ~ op ~ "= B.V[i];");
        }
        return this;
    }
 
    vec opBinary(string op)(T B)
    {
        vec R;
        foreach (i; 0..S)
        {
            mixin("R.V[i] = V[i] " ~ op ~ " B;");
        }
        return R;
    }
    
    vec opBinary(string op)(vec B)
    {
        vec R;
        foreach (i; 0..S)
        {
            mixin("R.V[i] = V[i] " ~ op ~ " B.V[i];");
        }
        return R;
    }
    
    T dot(vec B)
    {
        return reduce!"a+b"((this * B).V);
    }
    
    static Vector!(T,3) cross(Vector!(T,3) A, Vector!(T,3) B)
    {
        return Vector!(T,3)(
            [A.V[1]*B.V[2] - A.V[2]*B.V[1],
             A.V[2]*B.V[0] - A.V[0]*B.V[2],
             A.V[0]*B.V[1] - A.V[1]*B.V[0]]);
    }
    
    void print()
    {
        write("vec", S, "(");
        foreach (i; 0..S)
        {
            write(V[i]);
            if (i < S-1)
                write(",");
        }
        writeln(")");
    }
    

}

alias Vector!(float,2) vec2;
alias Vector!(float,3) vec3;
alias Vector!(float,4) vec4;

unittest
{
    // Test the static init.
    vec4 zeroes;
    assert(zeroes[0] == 0);
    
    // Test init from an array.
    vec4 A = [5, 1, 2, 3];
    assert(A.V == [5,1,2,3]);
    
    // Test multiply by a scalar .
    assert((A * 2).V == [10,2,4,6]);
    
    // Test multiply by a vector.
    vec4 B = [10, 8, 6, 4];
    assert((A*B).V == [50, 8, 12, 12]);
    assert((A*B) == (B*A));
    
    // Test subtract and assign with a scalar
    vec4 S = [0, -3, -7, -5];
    S -= 0.5;
    assert(S.V == [-0.5, -3.5, -7.5, -5.5]);
    
    // Test add and assign with vector.
    vec4 C = [10, 10, 10, 10];
    (C += B)[0] = -1; // Also test that it returns a ref.
    assert(C.V == [-1, 18, 16, 14]);
    
    // Test dot product of perpendicular vectors.
    vec3 D = [1, 0, 0];
    vec3 E = [0, 1, 0];
    assert(D.dot(E) == 0);
    
    // Test cross product of perpendicular vectors.
    assert(vec3.cross(D, E).V == [0, 0, 1]);
    
}

