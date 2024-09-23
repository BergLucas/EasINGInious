from inginious.frontend.user_manager import UserManager
from argparse import ArgumentParser
from pymongo import MongoClient
from getpass import getpass

USERNAME_DEFAULT = "superadmin"
REALNAME_DEFAULT = "INGInious SuperAdmin"
EMAIL_DEFAULT = "superadmin@inginious.org"
PASSWORD_DEFAULT = "superadmin"


def main() -> None:
    parser = ArgumentParser()
    parser.add_argument("--host", type=str, default="localhost")
    parser.add_argument("--port", type=int, default=27017)
    parser.add_argument("--database_name", type=str, default="INGInious")

    args = parser.parse_args()

    mongo_client = MongoClient(host=args.host, port=args.port)

    database = mongo_client[args.database_name]

    username = (
        input(f"Please enter the superadmin username: (default: '{USERNAME_DEFAULT}') ")
        or USERNAME_DEFAULT
    )
    realname = (
        input(f"Please enter the superadmin name: (default: '{REALNAME_DEFAULT}') ")
        or REALNAME_DEFAULT
    )
    email = (
        input(f"Please enter the superadmin email: (default: '{EMAIL_DEFAULT}') ")
        or EMAIL_DEFAULT
    )
    password = (
        getpass(
            f"Please enter the superadmin password: (default: '{PASSWORD_DEFAULT}') "
        )
        or PASSWORD_DEFAULT
    )

    database.users.insert_one(
        {
            "username": username,
            "realname": realname,
            "email": email,
            "password": UserManager.hash_password(password),
            "bindings": {},
            "language": "en",
        }
    )


if __name__ == "__main__":
    main()
