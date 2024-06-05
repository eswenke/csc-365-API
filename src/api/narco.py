from fastapi import APIRouter, Depends
from pydantic import BaseModel
from src.api import auth
import sqlalchemy
from src import database as db

router = APIRouter(
    prefix="/narco",
    tags=["narco"],
    dependencies=[Depends(auth.get_api_key)],
)

class Narcotic(BaseModel):
    name: str
    quantity: int
    # price: int
    # type: list[int]
    
@router.post("/consume/{citizen_id}")
def post_drugs_done(narcos_delivered: list[Narcotic], citizen_id:int):
    "Remove drugs from inventory, be cooler"

    with db.engine.begin() as connection:
        for narco in narcos_delivered: # Switch decrement number owned, increment coolness, dont if drug not owned
            in_table = connection.execute(sqlalchemy.text("""SELECT EXISTS (
                                                          SELECT 1 FROM inventory 
                                                          WHERE citizen_id = :cit_id
                                                          AND name = :narco_name
                                                          AND quantity > 0);"""),
                                    {'narco_name' : narco.name, 'cit_id' : citizen_id})
            # Determining coolness, quantity * rarity
            coolness = narco.quantity * connection.execute(sqlalchemy.text("""SELECT COALESCE((
                                                                     SELECT rarity FROM narcos 
                                                                     WHERE name = :drug_name 
                                                                     LIMIT 1), -1) as result;"""), 
                                                    {'drug_name' : narco.name}).scalar()
            
            if coolness < 0:
                return "Unidentified narcotic or impossible quantity"
            if in_table == 1: # Proceed with consumption
                connection.execute(sqlalchemy.text("""UPDATE inventory SET quantity = quantity - :quant WHERE name = :drug_name and citizen_id = :cit_id;
                                               UPDATE citizens SET coolness = coolness + :cool WHERE id = :cit_id;"""),
                                    {'cit_id' : citizen_id, 'cool' : coolness})
            else:
                return "Narco not found in inventory"

    print(f"narcos consumed: {narcos_delivered}")
    return "OK"