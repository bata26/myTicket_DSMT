import pandas as pd


FILE_NAME = "sales.csv"
LABEL_NAME = "la_event_type_cat"
CONCERT_LABEL_VALUE = "CONCERTS"

def cleanDataset():
    df = pd.read_csv(FILE_NAME,  encoding='latin-1')
    df2 = df.query("la_event_type_cat == @CONCERT_LABEL_VALUE")
    df2.to_csv("filtered.csv")


if __name__ == "__main__":
    cleanDataset()