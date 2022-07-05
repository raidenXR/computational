### Quadrature as Box counting

$$
\int_{a}^b
    f(x)dx \approx \sum_{i=1}^N f(x_i)w_i
$$

### Trapezoid Rule

$$
h = \frac {b - a} {N - 1} ~~,~~~~~~
x_i = a + (i - 1)h ~~,~~~~  i = 1,N
$$

$$
\int_a^b f(x)dx \approx \frac h 2 f_1 + hf_2 + hf_3 + \dots + hf_{N-1} + \frac h 2 f_N
$$

### Simpson's Rule

$$
\int_a^b f(x)dx \approx \frac h 3 f_1 + \frac {4h} 3 f_2 + \frac {2h} 3f_3 + \frac {4h} 3 f_4 + \dots + \frac {4h} 3 f_{N-1} + \frac h 3 f_N
$$

$$
w_i =  \Big \lbrace \frac h 3, \frac {4h} 3, \frac {2h} 3, \frac {4h} 2, \dots, \frac {4h} 3, \frac h 3   \Big \rbrace 
$$

### Gaussian Quadtrature

$$
\int _a^b f(x)dx \approx \sum _{i=1} ^N f(x_i)w_i 
$$

> TODO: add the rest of the mathematical definition
 , in source there is an error *w = inf* 
