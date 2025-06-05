INPUT_SCHEMA = {
    'workflow': {
        'type': str,
        'required': False,
        'default': 'vace-t2v',
        'constraints': lambda workflow: workflow in [
            'default',
            'vace-t2v',
            'custom'
        ]
    },
    'payload': {
        'type': dict,
        'required': True
    }
}
