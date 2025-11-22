local CreateEntityVisibilityHandle, GetEntityVisibility = CreateFactory(true, ComposeBoolean1, function(entityId, state)
    SetEntityVisible(entityId, state, false)
end)

exports('CreateEntityVisibilityHandle', CreateEntityVisibilityHandle)
exports('GetEntityVisibility', GetEntityVisibility)
