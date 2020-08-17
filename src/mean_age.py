def cm_mean_age(mx, nx):
    r"""
    Calculate :math:`a_x` assuming constant mortality over each interval.

    .. math::

       a_x = \frac{1}{m_x} - \frac{n_x e^{-m_x n_x}}{1-e^{-m_x n_x}}

    If :math:`m_x` is zero, this equation is infinite, but it
    clearly goes to :math:`a_x=n/2`. We handle this with an expansion
    around :math:`m_x=0`,

    .. math::

       a_x = \frac{n}{2} - \frac{n^2m}{12}+\frac{n^4m^3}{720}\cdots

    Args:
        mx: hazard rate for mortality, :math:`m_x`.
            Same as death rate under this assumption.
            Any Nans coming in will come out as Nans.
        nx: The width of intervals, :math:`n_x`.

    Returns:
        a_x: The mean age of death in each interval, :math:`a_x`.
    """
    # The approximation at small mx is good, so we can pick most any
    # cutoff value that isn't too small for the full calculation.
    smallest = 1e-6
    upper = mx >= smallest
    reg_mx = mx.where(upper)
    expx = xr.ufuncs.exp(-reg_mx * nx)
    base = (1 / reg_mx) - (nx * expx) / (1 - expx)
    mini_mx = mx.where(~upper)
    # Horner form
    rest = nx * (0.5 + nx * (-mini_mx/12 + mini_mx**3 * nx**2 / 720))
    total = base.combine_first(rest)
    # If nans come in, it's OK if they go out.
    assert total.isnull().sum() == mx.isnull().sum()
    return total
