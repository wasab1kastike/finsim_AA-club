# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2025-09-14
### Added
- Variable speed support for the GameClock.

### Changed
- Unified unit scripts.
- Clarified spawn unit typing and documentation.

### Removed
- Deprecated zoom smoothing.
- Bundled font and imported binary textures.

### Fixed
- Enum casting in `Unit.from_dict`.

## [0.2.0] - 2025-09-12
### Added
- Event system with preloaded resources.
- Raider manager for spawning and tracking hostile tiles.
- Building info panel and tutorial overlay scenes.

### Changed
- Refactored world and hex map to use `TileMapLayer` nodes.
- Renamed units and resources to Finnish terms.

### Fixed
- Map generator respects existing tiles.

## [0.1.0] - 2025-09-09
### Added
- Initial project skeleton and repository bootstrap.
- Core autoload singletons.
- World tilemap with building construction and hex tile map generation.
