---@meta hstate

---@class hstate
local hstate = {}

---@alias HStateHandle fun(): nil Release handle

---@class HStateComposeInput
---@field priority number readonly, write will cause unexpected behavior
---@field state userdata T, readonly, write will cause unexpected behavior

---@generic T
---@param defaultState T Default state when no handles exist
---@param compose fun(handles: HStateComposeInput[]): T Composer function to combine handle states
---@param onChange fun(entityId: number, state: T): nil Callback when composed state changes
---@param eq? fun(a: T, b: T): boolean Equality function to compare states, returns true if states are equal
---@return fun(entityId: number, state: T, priority: number): HStateHandle createHandle Create handle for an entity
---@return fun(entityId: number): T getState Get current state for an entity
function hstate.CreateFactory(defaultState, compose, onChange, eq) end

---@param trueHasHigherPriority boolean If true, true state takes precedence when priorities are equal
---@return fun(composeInputs: HStateComposeInput[]): boolean Composer function
function hstate.BooleanComposer(trueHasHigherPriority) end

---Boolean composer where true has higher priority
---@type fun(composeInputs: HStateComposeInput[]): boolean
hstate.ComposeBoolean1 = nil

---Create a handle for entity visibility control
---@type fun(entityId: number, state: boolean, priority: number): HStateHandle
hstate.CreateEntityVisibilityHandle = nil

---Get current visibility state for an entity
---@type fun(entityId: number): boolean
hstate.GetEntityVisibility = nil

---@type hstate
exports.hstate = hstate

return hstate
