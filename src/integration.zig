const std = @import("std");
const testing = std.testing;
const expect = std.testing.expect;
const print = std.debug.print;
const math = std.math;

const err = 0.00001;                // error
const Job = enum{ J0, J1, J2 };


export fn add(a: i32, b: i32) i32 {
    return a + b;
}

fn simpleFunction(x: f64) f64
{
    // x*x + 3x --> (4+6) - (1+3) = 6
    return 2.0 * x + 3.0;
}

pub fn abs(value: f64) callconv(.Inline) f64
{
    return if(value > 0.0) value else -value;
}

test "abs"
{
    try expect(10.0 == abs(-10.0));
}


pub fn trapezoid(f: fn(f64) f64, a: f64, b: f64) f64
{
    const N = 10001;                    // N points
    const h = (b - a) / double(N - 1);  // space distance h

    var sum: f64 = 0.0;
    var i: u32 = 1;
    var x: f64 = a;

    while(i < N - 1) : (i += 1)
    {
        x += h;
        sum += h * f(x);
    }
    
    sum += h*f(a)/2.0;
    sum += h*f(b)/2.0;

    return sum;
}

test "trapezoid"
{
    const _err = 0.5;
    const result = 6.0;
    const integral = trapezoid(simpleFunction, 1.0, 2.0);
    print("integral: {d}\n", .{integral});
    try expect(abs(result - integral) < _err); 
}

pub fn simpsonRule(f: fn(f64) f64, a: f64, b: f64) f64
{
    const N = 1001;
    const h = (b - a) / double(N - 1);

    var sum: f64 = 0.0;
    var i: u32 = 1;
    var x: f64 = a;

    while(i < N - 1) : (i += 1)
    {
        x += h;
        sum += if(i%2 == 0) 4.0*h/3.0 * f(x) else 2.0*h/3.0 * f(x);
    }

    sum += h*f(a)/3.0;
    sum += h*f(b)/3.0;

    return sum;
}

test "simpsonRule"
{
    const _err = 0.005;
    const result = 6.0;
    const integral = simpsonRule(simpleFunction, 1.0, 2.0);
    print("integral: {d}\n", .{integral});
    try expect(abs(result - integral) < _err);
}

fn double(int: u32) callconv(.Inline) f64
{
    return @intToFloat(f64, int);
}

// the y interval -1 < =yi < =1 must be mapped onto the x interval a <= x <= b... ???
// set breakpoints and debug with GDB in VSCode because w = inf
fn gaussIntegration(npts: u32, job: Job, a: f64, b: f64, x: []f64, w: []f64) void
{
    var m: u32 = 0;
    var t: f64 = 0.0;
    var t1: f64 = 0.0;
    var pp: f64 = 0.0;
    var p1: f64 = 0.0;
    var p2: f64 = 0.0;
    var p3: f64 = 0.0;
    var xi: f64 = undefined;
    
    m = (npts + 1)/2;

    var i: u32 = 1;
    while(i <= m) : (i += 1)
    {
        t = @cos(math.pi * (double(i) - 0.25) / (double(npts) + 0.5));
        t1 = 1.0;

        while(abs(t - t1) >= err)
        {
            p1 = 0.0;
            p2 = 0.0;

            var j: u32 = 1;
            while(j <= npts) : (j += 1)
            {
                p3 = p2;
                p2 = p1;
                p1 = (double(2*j-1)*t*p2 - double(j-1)*p3) / double(j);
            }

            pp = double(npts) * (t*p1 - p2) / (t*t - 1.0);
            t1 = t;
            t = t1 - p1/pp;
        }

        x[i - 1] = -t;
        x[npts - i] = t;
        w[i - 1] = 2.0 / ((1.0 - t*t) * pp*pp);     // divides with 0 ffs...
        w[npts - i] = w[i - 1]; 
    }
    
    switch(job)
    {
        Job.J0 =>
        {
            // for(0..npts) |I|
            var I: u32 = 0;
            while(I < npts) : (I += 1)
            {
                x[I] = x[I]*(b-a)/2.0 + (b+a)/2.0;
                w[I] = w[I]*(b-a)/2.0;
            }
        },
        Job.J1 =>
        {
            // for(0..npts) |I|
            var I: u32 = 0;
            while(I < npts) : (I += 1)
            {
                xi = x[I];
                x[I] = a*b*(1.0 + xi) / (b + a -(b-a) * xi);
                w[I] = w[I] * 2.0 * a*b*b / ((b+a-(b-a)*xi) * (b+a-(b-a)*xi));
            }    
        },
        Job.J2 =>
        {
            // for(0..npts) |I|
            var I: u32 = 0;
            while(I < npts) : (I += 1)
            {
                xi = x[I];
                x[I] = (b*xi + b + a + a) / (1.0 - xi);
                w[I] = w[I] * 2.0*(a + b) / ((1.0 - xi)*(1.0 - xi));
            }
        },
    }
}

pub fn gauss(f: fn(f64) f64, a: f64, b: f64, job: Job) !f64
{
    const N = 2001;

    const allocator = std.heap.page_allocator;
    var x = try allocator.alloc(f64, N);        // []f64
    var w = try allocator.alloc(f64, N);        // []f64
    defer allocator.free(x);
    defer allocator.free(w);

    var j: u32 = 0;
    while(j < N) : (j += 1)
    {
        x[j] = 0;
        w[j] = 0;
    }
    
    var sum: f64 = 0.0;
    var i: u32 = 0;

    gaussIntegration(N, job, a, b, x, w);   // calculates x and weights
    
    while(i < N) : (i += 1)
    {
        sum += f(x[i]) * w[i];
    }

    return sum;
}

test "gaussIntegration"
{
    const N = 2001;
    
    const allocator = std.heap.page_allocator;
    var x = try allocator.alloc(f64, N);        // []f64
    var w = try allocator.alloc(f64, N);        // []f64
    defer allocator.free(x);
    defer allocator.free(w);
    
    gaussIntegration(N, Job.J0, 1.0, 2.0, x, w);    // calculates x and weights
    
    var i: u32 = 0;
    while(i < N) : (i += 1)
    {
        const condition = !(x[i] > 1.0 and x[i] < 2.0) or !(w[i] > 0.0 and w[i] < 1.0);
        if(condition)
        {
            print("x: {d}, w: {d}\n", .{x[i], w[i]});
            try expect(!condition);
            break;
        }

    }
}

// WRITE TEST!!!!!!!!!!!!!!!!!
test "gauss"
{
    const _err = 0.005;
    const result = 6.0;
    const integral = try gauss(simpleFunction, 1.0, 2.0, Job.J0);
    print("integral: {d}\n", .{integral});
    try expect(abs(result - integral) < _err);
}
