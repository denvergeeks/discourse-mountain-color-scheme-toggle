import { apiInitializer } from "discourse/lib/api";
import MountainColorSchemeToggle from "../components/mountain-color-scheme-toggle";

export default apiInitializer("1.8.0", (api) => {
  api.headerIcons.add(
    "mountain-color-scheme-toggle",
    MountainColorSchemeToggle,
    {
      before: settings.toggle_before_icon || "search"
    }
  );
});
