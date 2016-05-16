# SimulationType is one of:
# - "exponencial"
# - "uniforme"
# - "normal"

# SimulationType List<Number> SimulationType List<Number> Natural -> List<Number>
# Returns the performance measures of the queueing system.
function R = simulation(arrivalType, arrivalParams, departureType, departureParams, s)
  # Set seed for testing.
  rand("seed", 3);
  # Get functions
  arrivalFunction = getFunction(arrivalType, arrivalParams);
  departureFunction = getFunction(departureType, departureParams);

  R = simulate(arrivalFunction, departureFunction, s)
end

# String List<Number> -> (Void -> Real)
# Given a supported random distribution function name and its params
# return a lambda to such random distribution function.
function fn = getFunction(type, params)
  fn = @() rand();
  if (strcmp(type, "exponencial"))
    fn = @() (-1 / params(1)) * log(1 - rand());
  elseif (strcmp(type, "normal"))
    fn = @() normalRandom(rand(), params(1), params(2));
  elseif (strcmp(type, "uniforme"))
    a = params(1);
    b = params(2);
    fn = @() rand()*(b - a) + a;
  endif
end

# Number Number Number -> Number
# Dados los parametros sigma y miu de una desviacion estandar, obtener una variable
# aleatoria x basada en un metodo especial que se adhiere a la probabilidad.
function x = normalRandom(R, sigma, miu)
  N = 12;
  r = 0;
  for j = 1 : N
    r = r + rand();
  endfor
  Z = r - (N / 2);
  x = sigma * Z - miu;
end

# (void -> real) (void -> real) natural -> list<Number>
# Given the arrival and departure distribution functions. Simulate
# a queueing system with s servers.
function R = simulate(arrivalFunction, departureFunction, s)
  R = 0;
  MAX_TIME = 500000;
  t = 0;
  n = 0;

  nextArrival = -1;
  nextDeparture = -1;
  totalN = 0;
  emptyTime = 0;
  # Total wait time in system.
  WS = 0;
  # Total wait time in queue.
  WQ = 0;

  # Main loop
  while (t < MAX_TIME)
    # If there are no clients in the system, get next arrival time
    # and update emptyTime with time until next arrival.
    if (n < s)
      nextArrival = arrivalFunction();
      nextDeparture = -1;
      emptyTime = emptyTime + nextArrival;
    else
      # Get times of next arrival and nextdeparture.
      if (nextArrival == -1)
        nextArrival = arrivalFunction();
      endif

      if (nextDeparture == -1)
        nextDeparture = departureFunction();
      endif
    endif

    # Update clients, waits in system, clock, and reset next time of event.
    if (nextDeparture == -1 || nextArrival <= nextDeparture)
      if (nextDeparture != -1)
        nextDeparture = nextDeparture - nextArrival;
      endif
      WS = WS + n * nextArrival;
      # If there is more than one client in the system, one is being processed.
      if (n > s)
        WQ = WQ + (n - s) * nextArrival;
      endif
      t = t + nextArrival;
      n = n + 1;
      totalN = totalN + 1;
      nextArrival = -1;
    else
      WS = WS + n * nextDeparture;
      # If next event is a departure, then only n - 1 clients are in queue
      # since one is in server.
      WQ = WQ + (n - s) * nextDeparture;
      nextArrival = nextArrival - nextDeparture;
      t = t + nextDeparture;
      n = n - 1;
      nextDeparture = -1;
    endif
  endwhile

  # Print simulation values.
  p0 = emptyTime / t
  L = WS / t
  W = WS / totalN
  Lq = WQ / t
  Wq = WQ / totalN

end
