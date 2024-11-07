function outputSignal = AGC(inputSignal, targetLevel, stepSize)
    outputSignal = zeros(size(inputSignal));
    storage = zeros(1, length(inputSignal));
    gain = 1;
    for n = 1:length(inputSignal)
        outputSignal(n) = gain * inputSignal(n);
        currentLevel = real(outputSignal(n)) + imag(outputSignal(n)); %abs(outputSignal(n));
        error = targetLevel - abs(currentLevel);
        gain = gain + stepSize * error;
        storage(n) = stepSize * error;
        if gain < 0
            gain = 0;
        end
    end
end 