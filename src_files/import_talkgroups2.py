import sys
import datetime
import csv
import re

from django.core.management.base import BaseCommand, CommandError
from django.conf import settings
from django.utils import timezone
from radio.models import *
from django.db.utils import IntegrityError

class Command(BaseCommand):
    help = 'Import talkgroup info'

    def add_arguments(self, parser):
        parser.add_argument('file')
        parser.add_argument(
            '--truncate',
            dest='truncate',
            action='store_true',
            help='Truncat any data that would not fit into the DB',
            default=False,
       )

    def handle(self, *args, **options):
        import_tg_file(self, options)


def import_tg_file(self, options):
    ''' Using the talkgroup file from trunk-recorder'''
    file_name = options['file']
    truncate = options['truncate']

    if truncate:
      mode_max_length = TalkGroup._meta.get_field('mode').max_length
      alpha_tag_max_length = TalkGroup._meta.get_field('alpha_tag').max_length
      description_max_length = TalkGroup._meta.get_field('description').max_length
    with open(file_name) as tg_file:
        tg_info = csv.reader(tg_file, delimiter=',', quotechar='"')
        next(tg_info, None)
        line_number = 0
        for row in tg_info:
            line_number+=1
            system_list = row[8]
            systems = system_list.split('|')
            for system in systems:
                if system.startswith("player"):
                    system_id = re.sub('[^0-9]','', system)
                    if (system_id == ''):
                        print("Skipping talkgroup", row[0] , "no system found in csv file")
                    else:
                        print("Found system_id", system_id, "for talkgroup", row[0], "in the csv file")
                        try:
                            system = System.objects.get(pk=system_id)
                            if truncate:
                                if len(row[3]) > mode_max_length:
                                  row[3] = row[3][:mode_max_length]
                                  self.stdout.write("Truncating mode from line ({}) TG {}".format(line_number, row[3]))
                                if len(row[2]) > alpha_tag_max_length:
                                  row[2] = row[2][:alpha_tag_max_length]
                                  self.stdout.write("Truncating alpha_tag from line ({}) TG {}".format(line_number, row[3]))
                                if len(row[4]) > description_max_length:
                                  row[4] = row[4][:description_max_length]
                                  self.stdout.write("Truncating description from line ({}) TG {}".format(line_number, row[3]))
                            obj, create = TalkGroup.objects.update_or_create(dec_id=row[0], system=system, defaults={'mode': row[3], 'alpha_tag': row[2], 'description': row[4], 'priority': row[7]})
                            obj.service_type = row[5]
                            print("Importing talkgroup", row[0], "for system #{} - {}".format(system.pk, system.name))
                            obj.save()
                        except System.DoesNotExist:
                            print("Skipping talkgroup", row[0] , "no system:", system)
                        except (IntegrityError, IndexError):
                            print("Skipping {}".format(row[3]))
