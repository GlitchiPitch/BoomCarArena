export type Car = Model & {
    DriveSeat: Seat,
    IsAlive: BoolValue,
    Hitbox: Part & {
        Bomb: Part?,
        BombAttachment: Attachment,
        Weld: WeldConstraint,
    }
}

export type Bomb = {
    SurfaceGui: SurfaceGui & {
        Label: TextLabel,
    }
}

export type ServerData = {
    carPrefab: Car,
    bombPrefab: Part,
    carFolder: Folder,
    spawnPoints: Folder & {Part},
    currentBomb: ObjectValue,
}

return true