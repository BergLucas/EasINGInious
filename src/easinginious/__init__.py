from argparse import ArgumentParser
from inginious.frontend.installer import Installer
from inginious.frontend.user_manager import UserManager

import inginious.common.custom_yaml as yaml
import os


def create_super_admin(file: str) -> None:
    """Create a new superadmin user.

    Args:
        file: Path to the configuration file.
    """
    installer = Installer()

    try:
        with open(file, "r") as f:
            options: dict = yaml.load(f)
    except FileNotFoundError:
        installer._display_error(f"Configuration file not found: {file}")
        return

    mongo_opt: dict[str, str] = options.get("mongo_opt", {})
    host = mongo_opt.get("host", "localhost")
    database_name = mongo_opt.get("database", "INGInious")

    database = installer.try_mongodb_opts(host, database_name)

    if database is None:
        installer._display_error("Failed to connect to the database.")
        return

    username = installer._ask_with_default(
        "Enter the login of the superadmin",
        "superadmin",
    )
    realname = installer._ask_with_default(
        "Enter the name of the superadmin",
        "INGInious SuperAdmin",
    )
    email = None
    while not email:
        email = installer._ask_with_default(
            "Enter the email address of the superadmin",
            "superadmin@inginious.org",
        )
        email = UserManager.sanitize_email(email)
        if email is None:
            installer._display_error("Invalid email format.")

    password = installer._ask_with_default(
        "Enter the password of the superadmin",
        "superadmin",
    )

    database.users.insert_one(
        {
            "username": username,
            "realname": realname,
            "email": email,
            "password": UserManager.hash_password(password),
            "bindings": {},
            "code_indentation": "4",
            "language": "en",
        }
    )

    if "superadmins" not in options:
        options["superadmins"] = []

    options["superadmins"].append(username)

    with open(file, "w") as f:
        yaml.dump(options, f)


def main() -> None:
    """Main entry point of the easinginious app."""
    parser = ArgumentParser(
        description="EasINGInious - Simplifying INGInious installation"
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    superadmin_parser = subparsers.add_parser(
        "createsuperadmin",
        help="Create a new superadmin user",
    )
    superadmin_parser.add_argument(
        "--file",
        help="Path to configuration file. If not set, use the default for the given frontend.",
        default=os.environ.get("INGINIOUS_WEBAPP_CONFIG", ""),
    )

    subparsers.add_parser(
        "buildcontainers",
        help="Build the Docker containers",
    )

    args = parser.parse_args()

    if args.command == "createsuperadmin":
        create_super_admin(args.file)
    elif args.command == "buildcontainers":
        Installer().select_containers_to_build()
    else:
        parser.print_help()
