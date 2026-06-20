import { apiInitializer } from "discourse/lib/api";
import MountainColorSchemeToggle from "../components/mountain-color-scheme-toggle";

export default apiInitializer((api) => {
  api.headerIcons.add("mountain-color-scheme-toggle", MountainColorSchemeToggle, {
    before: settings.insert_before_icon || "search",
  });
});
