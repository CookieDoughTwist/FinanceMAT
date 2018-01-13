function record_prices(interval)
    if nargin < 1
        interval = 10;
    end
    import matlab.net.*
    import matlab.net.http.*
    r = RequestMessage;
    uri = URI('https://api.binance.com/api/v1/ticker/allPrices');
    while true
        nonsleep = tic;
        try
            resp = send(r,uri);
        catch
            resp = [];
            disp('Send failed!');
        end
        if isempty(resp)
            continue;
        end
        data = resp.Body.Data; %#ok<NASGU>
        current_posix = num2str(posixtime(datetime));
        fprintf('Current time: %s\n',current_posix);
        filename = ['./PriceData/' current_posix '.mat'];
        save(filename,'data');
        execution_time = toc(nonsleep);
        pause_time = max(interval-execution_time,0);
        pause(pause_time);
    end
end

