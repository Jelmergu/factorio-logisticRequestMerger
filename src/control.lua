require "helpers"

script.on_init(function ()
    if global['requestMerger'] == nil then
        global['requestMerger'] = {}
    end
end)

script.on_configuration_changed(function ()
    if global['requestMerger'] == nil then
        global['requestMerger'] = {}
    end
end)

script.on_event(defines.events.on_pre_entity_settings_pasted,
        function(event)
            local source = event.source
            local destination = event.destination

            if is_requestingContainer(source) == false or is_requestingContainer(destination) == false then
                return
            end

            local sourceRequest = source.get_logistic_point(defines.logistic_member_index.logistic_container).filters

            for _, value in ipairs(sourceRequest) do
                if mergeItem(destination, value) ~= true then
                    addItem(destination, value)
                end
            end
            if global['requestMerger'] == nil then
                global['requestMerger'] = {}
            end
            global['requestMerger'][event.player_index] = destination.get_logistic_point(defines.logistic_member_index.logistic_container).filters
        end)

script.on_event(defines.events.on_entity_settings_pasted,
        function(event)
            if global['requestMerger'][event.player_index] ~= nil then
                local requests = global['requestMerger'][event.player_index]

                for _, value in ipairs(requests) do
                    event.destination.set_request_slot({ name = value.name, count = value.count}, value.index)
                end

                if global['requestMerger'] == nil then
                    global['requestMerger'] = {}
                end

                global['requestMerger'][event.player_index] = nil
            end
        end)

function is_requestingContainer(entity)
    return entity.prototype.logistic_mode == "buffer" or entity.prototype.logistic_mode == "requester"
end

function mergeItem(destination, request)
    local requests = destination.get_logistic_point(defines.logistic_member_index.logistic_container).filters
    if count(requests) > 0 then
        for i, value in ipairs(requests) do
            if value.name == request.name then
                destination.clear_request_slot(i)
                destination.set_request_slot({ name = value.name, count = value.count + request.count }, i)
                return true
            end
        end
    end
    return false
end

function addItem(destination, request)
    local requests = destination.get_logistic_point(defines.logistic_member_index.logistic_container).filters
    local index = 1
    var_dump(request)
    var_dump(requests)
    if count(requests) > 0 then
        for key, value in ipairs(requests) do
            echo("index: " .. index)
            if value.index == index then
                echo("request at index " .. key)
                var_dump(value)
                index = index + 1
            else
                echo("breaking")
                break
            end
        end
    end
    echo("ending index: " .. index)
    destination.set_request_slot({ name = request.name, count = request.count }, index)
end