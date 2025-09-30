# Changelog

# [0.13.0](https://github.com/mfkiwl/Tracking.jl/compare/v0.12.5...v0.13.0) (2025-09-30)


### Bug Fixes

* detect secondary code or bit before bits are buffered ([#58](https://github.com/mfkiwl/Tracking.jl/issues/58)) ([6aad4c3](https://github.com/mfkiwl/Tracking.jl/commit/6aad4c3bc624745ec48f4e5e0239493411be6f24))
* detection of complete integration ([#57](https://github.com/mfkiwl/Tracking.jl/issues/57)) ([6fdb61d](https://github.com/mfkiwl/Tracking.jl/commit/6fdb61d16185ec438b4d89daa990c7a379aabab6))
* use correct earliest and latest sample shift in gen_code_replica function ([a0be2d7](https://github.com/mfkiwl/Tracking.jl/commit/a0be2d7c761e124d9b49e599070f7e636a24f43b))
* use correct latest sample shift in correlate function ([8b8b49b](https://github.com/mfkiwl/Tracking.jl/commit/8b8b49b9c402ae5409ab43bbd4231515d886d457))


### Features

* add possibility to inject a post process ([#49](https://github.com/mfkiwl/Tracking.jl/issues/49)) ([a243dac](https://github.com/mfkiwl/Tracking.jl/commit/a243dac458714270ccb28a4f0f3042c798e907c8))
* simplify cpu buffers ([#62](https://github.com/mfkiwl/Tracking.jl/issues/62)) ([b40bd10](https://github.com/mfkiwl/Tracking.jl/commit/b40bd1057d599ba20bf46ce34c59d4c0c95637d3))
* some convenient methods for easier access of states ([#61](https://github.com/mfkiwl/Tracking.jl/issues/61)) ([246c875](https://github.com/mfkiwl/Tracking.jl/commit/246c875a68f16c11c986e277c108a93abaa41d63))
* use bit detector buffer to fill bit buffer once found ([#60](https://github.com/mfkiwl/Tracking.jl/issues/60)) ([dbc5fce](https://github.com/mfkiwl/Tracking.jl/commit/dbc5fce2c7f7298726a2760c27307fb5eadc0168))
