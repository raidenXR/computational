### Differentiation
Algorithms for differentiation

$$
\frac {df(x)} {dx} \overset{def}{=} \lim_{h \rarr 0} \frac {f(x+h) - f(x)} {h}
$$

###  forward-difference

$$
\frac {df(x)} {dx} \approx \frac {f(x+h) - f(x)} {h} \tag{h: distance}
$$

### central-difference

$$
\frac {df(x)} {dx} \approx \frac {f(x+ \frac h 2) - f(x - \frac h 2)} {h}
$$

### forward-difference

$$
\frac {df(x)} {dx} \approx \frac{1 }{3h} \bigg \lbrace 8 \bigg \lbrack f \big(x + \frac h 4 \big) - f \big( x - \frac h 4 \big) \bigg \rbrack - \bigg \lbrack f \big( x+ \frac h 2) - f \big( x - \frac h 2 \big) \bigg \rbrack \bigg \rbrace
$$

### Second Derivative
$$
\frac {d^2f(x)} {dx^2} \approx \frac { f'(x+ \frac h 2) - f'(x - \frac h 2)} {h} \\ ~ \\ \approx \frac {f(x+h) - f(x-h) - 2f(x)} {h^2}
$$
