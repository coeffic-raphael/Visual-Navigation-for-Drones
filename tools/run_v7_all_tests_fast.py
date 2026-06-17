from __future__ import annotations

"""
Fast preview runner for V7 realtime tests.

This reuses tools/run_v7_all_tests_good.py, but writes to outputs/realtime_fast/
and lowers the expensive runtime settings for speed/accuracy experiments.

Fast preset:
  sample-fps: 2 -> 1
  lightglue-every: 2 -> 4
  global-topk: 100 -> 60
  candidate-pool-limit: 90 -> 60
  lg-topk: 12 -> 8

Use this for experiments only. Keep tools/run_v7_all_tests_good.py for final reported results.
"""

import run_v7_all_tests_good as good

# Save the original function BEFORE replacing it. Without this, fast_v7_args()
# calls itself forever and crashes with RecursionError.
_ORIGINAL_OLD_GOOD_V7_ARGS = good.old_good_v7_args


def fast_v7_args() -> list[str]:
    args = _ORIGINAL_OLD_GOOD_V7_ARGS()

    replacements = {
        "--sample-fps": "1",
        "--global-topk": "60",
        "--candidate-pool-limit": "60",
        "--lg-topk": "8",
        "--lightglue-every": "4",
    }

    for flag, new_value in replacements.items():
        try:
            i = args.index(flag)
        except ValueError as exc:
            raise RuntimeError(f"Expected flag not found in old_good_v7_args(): {flag}") from exc
        args[i + 1] = new_value

    return args


def main() -> None:
    good.OUTPUTS = good.ROOT / "outputs" / "realtime_fast"
    good.old_good_v7_args = fast_v7_args
    print("=" * 72)
    print("FAST V7 PREVIEW RUNNER")
    print("Output root: outputs/realtime_fast/")
    print("Changes from old/good V7:")
    print("  sample-fps: 2 -> 1")
    print("  global-topk: 100 -> 60")
    print("  candidate-pool-limit: 90 -> 60")
    print("  lg-topk: 12 -> 8")
    print("  lightglue-every: 2 -> 4")
    print("=" * 72)
    good.main()


if __name__ == "__main__":
    main()
