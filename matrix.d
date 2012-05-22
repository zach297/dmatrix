module dmatrix.matrix;

import std.algorithm, std.math, std.random, std.stdio;
import vector;

struct Matrix(T, size_t S=4)
{
    private alias Matrix!(T, S) mat;

    private T[S][S] A;
    
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
        T[] V = new T[4*4];
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
    

    mat multiply(mat B)
    {
        mat C;
        
        foreach(x; 0..S)
        {
            foreach(y; 0..S)
            {
                T[S] V;
                foreach (i; 0..S)
                    V[i] = A[i][y] * B.A[x][i];
                C.A[x][y] = reduce!"a+b"(V);
            }
        }
        
        return C;
        
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
    
    static mat createPerspective(real aspect, real fov, real near, real far)
    {
        mat A;
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
    
    static Matrix!(T,3) createRotation(vec3
    
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
                A[x,y] = uniform(0.0, 1.0);
            }
        }
        return A;
    }
    
    unittest
    {
        alias Matrix!(real,4) mat4;
        
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
    }
}

alias Matrix!(float,4) mat4;

int main()
{
    return 0;
}