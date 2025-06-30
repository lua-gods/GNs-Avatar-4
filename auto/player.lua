vanilla_model.CAPE:setVisible(false)
vanilla_model.ELYTRA:setVisible(false)
vanilla_model.PLAYER:setVisible(false)


models.player.Base.Torso.Body.Cape:setPrimaryTexture("CAPE")
models.player.Base.Torso.Body.RightElytra:setPrimaryTexture("CAPE"):scale(1.1,1.1,2.4)
models.player.Base.Torso.Body.LeftElytra:setPrimaryTexture("CAPE"):scale(1.1,1.1,2.4)
models.player.Base.Torso.Head["Hat Layer"]:setPrimaryRenderType("TRANSLUCENT")


--models.player:setPrimaryTexture("SKIN")
--animations.player.california:play()