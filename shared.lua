-- -----------------------------------------------------------------------------
-- core
-- -----------------------------------------------------------------------------

---@generic T
---@param defaultState T Default state when no handles exist
---@param compose fun(handles: HStateComposeInput[]): T Composer function to combine handle states
---@param onChange fun(entityId: number, state: T): nil Callback when composed state changes
---@param eq? fun(a: T, b: T): boolean Equality function to compare states, returns true if states are equal
---@return fun(entityId: number, state: T, priority: number): HStateHandle createHandle Create handle for an entity
---@return fun(entityId: number): T getState Get current state for an entity
function CreateFactory(defaultState, compose, onChange, eq)
    ---@class StorageEntry
    ---@field lastState userdata
    ---@field handles table<integer, HStateHandle>
    ---@field composeInputs table<integer, HStateComposeInput>

    ---@type table<number, StorageEntry>
    local storage = {}

    -- Recalculate and apply state for an entity, cleanup if no handles are left
    -- precondition: storage[entityId] is set
    local function updateState(entityId)
        local entry = storage[entityId]

        if #entry.handles == 0 then
            onChange(entityId, defaultState)
            storage[entityId] = nil
            return
        end

        local composedState = compose(entry.composeInputs)
        local isSame = composedState == entry.lastState
        if eq then
            isSame = eq(composedState, entry.lastState)
        end
        entry.lastState = composedState

        if not isSame then
            onChange(entityId, composedState)
        end
    end

    ---@param entityId number
    ---@param composeInput HStateComposeInput
    local function removeHandleByComposeInput(entityId, composeInput)
        local entry = storage[entityId]
        if not entry then
            return
        end

        for i, c in ipairs(entry.composeInputs) do
            if c == composeInput then
                local lastIndex = #entry.handles
                table.remove(entry.handles, i)
                entry.handles[i] = entry.handles[lastIndex]
                entry.handles[lastIndex] = nil
                table.remove(entry.composeInputs, i)
                entry.composeInputs[i] = entry.composeInputs[lastIndex]
                entry.composeInputs[lastIndex] = nil
                updateState(entityId)
                return
            end
        end
    end

    ---@param entityId number
    ---@param state userdata T
    ---@param priority number
    ---@return HStateHandle
    local function createHandle(entityId, state, priority)
        if not storage[entityId] then
            storage[entityId] = {
                lastState = defaultState,
                handles = {},
                composeInputs = {}
            }
        end
        local entry = storage[entityId]

        ---@type HStateComposeInput
        local newComposeInput = {
            priority = priority,
            state = state,
        }
        ---@type HStateHandle
        local newHandle = function()
            removeHandleByComposeInput(entityId, newComposeInput)
        end

        table.insert(entry.handles, newHandle)
        table.insert(entry.composeInputs, newComposeInput)

        updateState(entityId)

        return newHandle
    end

    local function getState(entityId)
        local entry = storage[entityId]
        if not entry then
            return defaultState
        end
        return entry.lastState
    end

    return createHandle, getState
end

exports('CreateFactory', CreateFactory)


-- -----------------------------------------------------------------------------
-- utils
-- -----------------------------------------------------------------------------

---@param trueHasHigherPriority boolean
function BooleanComposer(trueHasHigherPriority)
    ---@param composeInputs HStateComposeInput[]
    return function(composeInputs)
        local highestPriority
        local result
        for _, input in ipairs(composeInputs) do
            if not highestPriority or input.priority > highestPriority then
                highestPriority = input.priority
                result = input.state
            elseif input.priority == highestPriority and trueHasHigherPriority == input.state then
                result = input.state
            end
        end
        return result
    end
end

exports('BooleanComposer', BooleanComposer)

ComposeBoolean1 = BooleanComposer(true)

exports('ComposeBoolean1', ComposeBoolean1)
