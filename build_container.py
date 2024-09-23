from inginious.frontend.installer import Installer


def main() -> None:
    installer = Installer()
    installer.select_containers_to_build()


if __name__ == "__main__":
    main()
