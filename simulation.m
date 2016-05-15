# SimulationType is one of:
# - "exponencial"
# - "uniforme"
# - "normal"

# SimulationType List<Number> SimulationType List<Number> Natural -> List<Number>
# Returns the performance measures of the queueing system.
function R = simulation(arrivalType, arrivalParams, departureType, departureParams, s)
  # Set seed for testing.
  % rand("seed", 3);
  # Get functions
  arrivalFunction = getFunction(arrivalType, arrivalParams);
  departureFunction = getFunction(departureType, departureParams);

  R = simulate(arrivalFunction, departureFunction, s)
end

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
  MAX_TIME = 1000000;
  t = 0;
  n = 0;
  nextArrival = arrivalFunction();
  nextDeparture = -1;
  nextEventType = "arrival";

  maxN = 0;
  totalN = 0;

  emptyTime = 0;
  WS = 0;
  WQ = 0;

  while (t < MAX_TIME)
    % n
    % t
    % nextArrival
    % nextDeparture
    % nextEventType
    if (strcmp(nextEventType, "arrival"))
      t = nextArrival;
      nextArrival = -1;
      n = n + 1;
      totalN = totalN + 1;
    else
      t = nextDeparture;
      nextDeparture = -1;
      n = n - 1;
    endif

    if (n == 0)
      if (nextArrival == -1)
        nextArrival = t + arrivalFunction();
      endif

      emptyTime = nextArrival - t + emptyTime;
      nextDeparture = -1;
      nextEventType = "arrival";
    else
      if (nextArrival == -1)
        nextArrival = t + arrivalFunction();
      endif

      if (nextDeparture == -1)
        nextDeparture = t + departureFunction();
      endif

      if (nextArrival > nextDeparture)
        nextEventType = "departure";
        WS = WS + n * (nextDeparture - t);
        if (n > 1)
          WQ = WQ + (n - 1) * (nextDeparture - t);
        end
      else
        nextEventType = "arrival";
        WS = WS + n * (nextArrival - t);
        WQ = WQ + (n - 1) * (nextArrival - t);
      endif
    endif
  endwhile

  p0 = emptyTime/t
  L = WS / t
  W = WS / totalN
  Lq = WQ / t
  Wq = WQ / totalN

end

function R = simulationLoop(arrivalFunction, departureFunction, s)
  MAX_TIME = 50000;
  t = 0;
  n = 0;

  isNextArrival = true;
  while (t < MAX_TIME)
      if (isSystemEmpty(n))
        t = arrivalFunction() + t;
        isNextArrival = true;
      else
        onNewEvent(isNextArrival, n)
      end
  end
end

function R = onNewEvent(isArrival, n, arrivalFunction, departureFunction)
  t = 0;
  if (isArrival)
    n = n + 1;
    t = arrivalFunction();
  else
    n = n - 1;
    t = departureFunction();
  end
end